From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Sun, 25 Nov 2007 12:27:03 -0800
Message-ID: <adatznarrzc.fsf@cisco.com>
References: <20071122343.446909000@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:46885 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185AbXKYU1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 15:27:06 -0500
In-Reply-To: <20071122343.446909000@suse.de> (Andi Kleen's message of "Thu, 22 Nov 2007 03:43:06 +0100 (CET)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > This patch allows to export symbols only for specific modules by 
 > introducing symbol name spaces. A module name space has a white
 > list of modules that are allowed to import symbols for it; all others
 > can't use the symbols.
 > 
 > It adds two new macros: 
 > 
 > MODULE_NAMESPACE_ALLOW(namespace, module);

I definitely like the idea of organizing exported symbols into
namespaces.  However, I feel like it would make more sense to have
something like

MODULE_NAMESPACE_IMPORT(namespace);

inside the modules that use a namespace.  This matches the way C
preprocessor #includes, C++ namespaces, perl "use", etc. works and so
it is probably closer to how programmers think.  It does weaken the
enforcement of review a little bit, since there are no changes to the
site where things are exported to catch, but git makes it easy to
sneak that kind of change in anyway.

The practical benefits are that you don't end up with stupid patch
conflicts caused by one patch adding MODULE_NAMESPACE_ALLOW() for
module "foo" and another patch adding it for module "bar" at the same
place, and that it becomes simpler for people to test or deliver, say,
a new TCP congestion module without having to rebuild the whole kernel
(which is an especially huge pain for distro kernels).

In any case I would make use of this in whatever form it gets merged
in -- Mellanox ConnectX hardware can operate simultaneously as an
InfiniBand adapter and a 10Gb ethernet NIC, and so my driver is split
up into a low-level mlx4_core driver that exports symbols for other
mlx4 drivers to use; clearly it only makes sense to export them to
other parts of the driver, and in this case the difference between
"ALLOW" and "IMPORT" semantics is not a big deal.

 - R.
