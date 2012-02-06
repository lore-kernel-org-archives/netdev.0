From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] CONFIG_TR/CONFIG_LLC: work around the problem with
 select
Date: Mon, 6 Feb 2012 13:51:50 +0000
Message-ID: <1328536310.2751.11.camel@bwh-desktop>
References: <20120205063139.GB23916@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7075 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754853Ab2BFNvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 08:51:54 -0500
In-Reply-To: <20120205063139.GB23916@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-02-05 at 06:31 +0000, Al Viro wrote:
> As it is, with PCI/ISA/MCA/CCW all set to n and PCMCIA set to m
> setting TR to y will set LLC to m, with very unpleasant results -
> net/802/psnap gets picked into obj-y, resulting in the kernel
> that won't link - psnap calls functions from llc.  The cause,
> AFAICS, is that kconfig gets rev_dep for LLC containing
> || TR && (deps for TR)
> and even though TR is boolean, both LLC and PCMCIA are tristate
> and that thing becomes || y && (n || m), i.e. || m.  The reason
> for dependency on PCMCIA is that when none of PCI, ISA, MCA, CCW
> or PCMCIA is set there'll be no tokenring drivers, so there's no
> point building tokenring core.  Proper fix probably belongs in
> kconfig (we need strict and, such that y <strict_and> m would be
> y, so that rev_deps added for tristate selected by bool would
> use that instead of &&; we'd have || TR <strict_and> (deps for TR)
> in this case), but it's a rather intrusive change.  There's an
> easy workaround in case of TR -> LLC select, namely to have a def_bool y
> symbol sitting under if TR and have that symbol selecting LLC.
> Kudos to johill for suggesting that one...
[...]

This is pretty subtle; maybe it warrants a comment above WANT_LLC?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
