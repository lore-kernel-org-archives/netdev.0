From: "Alon Bar-Lev" <alon.barlev@gmail.com>
Subject: Re: iproute2 (addr flush) infinite loop when unprivileged users
Date: Sat, 26 Jan 2008 10:58:58 +0200
Message-ID: <9e0cf0bf0801260058s797d2ea3r7af013d0957554d8@mail.gmail.com>
References: <9e0cf0bf0801251500u388b9a5dxda92d6d1e3d86233@mail.gmail.com>
	 <20080125161259.0356c990@deepthought>
	 <9e0cf0bf0801251622w203c515fn80cba5f233bd599d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:62828 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbYAZI67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 03:58:59 -0500
Received: by ug-out-1314.google.com with SMTP id z38so650981ugc.16
        for <netdev@vger.kernel.org>; Sat, 26 Jan 2008 00:58:58 -0800 (PST)
In-Reply-To: <9e0cf0bf0801251622w203c515fn80cba5f233bd599d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/26/08, Alon Bar-Lev <alon.barlev@gmail.com> wrote:
> On 1/26/08, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > The issue is that iproute is just blindly sending the deletes and
> > not asking for acknowledgment status. Here is a trivial patch to iproute
> > to fix that, but the problem is that it means it will slow down bulk removal.
> >
> > Maybe it should just check the first, or last delete to see if there are
> > errors?
> >
> > diff --git a/ip/iproute.c b/ip/iproute.c
> > index 7a885b0..b2ae879 100644
> > --- a/ip/iproute.c
> > +++ b/ip/iproute.c
>
> This should also be applied into ip/ipaddress.c, ip/ipneigh.c
> Or even make one common function?
>
> I don't quite understand how "fast" is good if not complete... But
> anyway... I will be happy to see this fix in next version... Maybe add
> --fast argument? :)
>
> Alon.
>

Pulled your latest git head. See some updates but not this one...
Just thought to report the following [new] build error:


gcc -Wl,-export-dynamic  ip.o ipaddress.o iproute.o iprule.o rtm_map.o
iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o
ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o ipxfrm.o xfrm_state.o
xfrm_policy.o xfrm_monitor.o iplink_vlan.o link_veth.o
../lib/libnetlink.a ../lib/libutil.a  -lresolv -L../lib -lnetlink
-lutil -ldl -o ip
iptunnel.o: In function `parse_args':
iptunnel.c:(.text+0x2f6): undefined reference to `__constant_htons'
iptunnel.c:(.text+0x434): undefined reference to `__constant_htons'
iptunnel.c:(.text+0x4c1): undefined reference to `__constant_htons'
iptunnel.c:(.text+0x4da): undefined reference to `__constant_htons'
iptunnel.c:(.text+0x51c): undefined reference to `__constant_htons'
iptunnel.o:iptunnel.c:(.text+0x535): more undefined references to
`__constant_htons' follow
collect2: ld returned 1 exit status
make[1]: *** [ip] Error 1
