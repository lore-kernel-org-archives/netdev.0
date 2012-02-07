From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CONFIG_TR/CONFIG_LLC: work around the problem with
 select
Date: Tue, 07 Feb 2012 13:06:47 -0500 (EST)
Message-ID: <20120207.130647.2102701372922806986.davem@davemloft.net>
References: <20120205063139.GB23916@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428Ab2BGSGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:06:54 -0500
In-Reply-To: <20120205063139.GB23916@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sun, 5 Feb 2012 06:31:39 +0000

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
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Applied, thanks.
