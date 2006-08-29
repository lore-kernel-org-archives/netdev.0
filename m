From: Olaf Kirch <okir@suse.de>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 12:44:18 +0200
Message-ID: <20060829104418.GI1201@suse.de>
References: <20060829082435.GA2676@suse.de> <20060829.183426.52410264.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jbeulich@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:64202 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932266AbWH2KoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 06:44:20 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20060829.183426.52410264.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2006 at 06:34:26PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > The attached tentative patch makes IPv6 autoconf depend on the
> > availability of IFF_MULTICAST. This is admittedly a bit of a hack, but
> > it makes sense, since DAD and router solicitation do rely on multicast.
> 
> I disagree.  The node MUST NOT assign live address on
> that interface.

I'm not sure I understand. The Xen bridge devices get fe:ff:ff:ff:ff:ff
as MAC address.  Which is a bit hackish, but that seems to be the way
the Xen folks want to do it.

OTOH they do not want to do any IPv6 autoconfiguration with these
addresses, because they generate DAD warnings, and cause one
random machine to obtain fe80::ffff:ffff:feff:ffff as link-local
address.

> Further analysis is needed, but one idea is to skip
> addrconf_dev_config() if !(dev->flags & IFF_MULTICAST).

That should work just as well. Do you want me to submit an
updated patch?

Thanks,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
