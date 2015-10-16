From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Thu, 15 Oct 2015 23:50:07 -0700 (PDT)
Message-ID: <20151015.235007.973370825335101214.davem@davemloft.net>
References: <cover.1444926905.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbbJPGd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 02:33:59 -0400
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 15 Oct 2015 18:39:05 +0200

> When sending a netlink request (NLM_F_REQUEST), any unknown attributes are
> ignored. This behavior is problematic in some situations. For example if the
> user asks for a particular config, the request finishes successfully, yet
> the configuraton applied does not work because some of the attributes are
> not supported by the kernel (e.g. because it's older than the user space
> tool).

Although we are probably stuck with this, it was probably a bad idea
to have this behavior as the default.

Better would have been to always error on unrecognized attributes, and
in the ACK give some indication of which attribute was problematic.

But anyhow we are stuck with what we have.  However, I will say I am
disappointed that it is so hard to simply detect that lwtunnel support
is present, which as I understand is what this patch set is trying to
accomplish.

And this is quite an intrusive patch series, and therefore not
suitable for -stable backports.  And that's exactly where you actually
are going to need these changes right?  Older kernels that lack
lwtunnel support.
