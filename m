From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: Why does IPV6 link local address advertised as /64?
Date: Wed, 12 Nov 2008 07:29:12 +0200
Message-ID: <20081112052912.GX30968@mea-ext.zmailer.org>
References: <20081111204906.081d9d57@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:48529 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbYKLF3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 00:29:16 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S2261317AbYKLF3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 07:29:12 +0200
Content-Disposition: inline
In-Reply-To: <20081111204906.081d9d57@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 08:49:06PM -0800, Stephen Hemminger wrote:
> It seems to make more sense to have only the actual host (ie /128)
> on the link-local address or is there some other purpose to
> using a /64?

The purpose of the link-local prefixes is not to report interface
physical address, but enable communication without yet having
full configuration in place  -  this enables ZeroConfig, DHCP6,
etc. mechanisms.

Consider Ethernet with link-local address, you can do peer-to-peer
communication there without global addresses by using MAC address
derived link-local address.  Indeed the global prefix RA's are
link-local multicasts.

Furthermore, with links using _same_ /64 prefix and possibly varying
suffix, all applications using the link-local addresses must also
inform socket binding of the interface where it is to be applied to.

         /Matti Aarnio
