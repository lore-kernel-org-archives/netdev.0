From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [net-next PATCH 00/02] net/ipv4: Add support for new tunnel type
 VTI.
Date: Tue, 12 Jun 2012 18:17:10 +0200
Message-ID: <4FD76B86.50009@6wind.com>
References: <20120608173225.GA11928@debian-saurabh-64.vyatta.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Saurabh <saurabh.mohan@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56768 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab2FLQRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 12:17:14 -0400
Received: by eaak11 with SMTP id k11so2256549eaa.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 09:17:13 -0700 (PDT)
In-Reply-To: <20120608173225.GA11928@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

thank you for pushing this feature upstream Saurabh.
This feature is very usefull, we have implemented something similar in =
our system.

Regards,
Nicolas

Le 08/06/2012 19:32, Saurabh a =E9crit :
>
>
> Introduction:
> Virtual tunnel interface is a way to represent policy based IPsec tun=
nels as virtual interfaces in linux. This is similar to Cisco's VTI (vi=
rtual tunnel interface) and Juniper's representaion of secure tunnel (s=
t.xx). The advantage of representing an IPsec tunnel as an interface is=
 that it is possible to plug Ipsec tunnels into the routing protocol in=
frastructure of a router. Therefore it becomes possible to influence th=
e packet path by toggling the link state of the tunnel or based on rout=
ing metrics.
>
> Overview:
> Natively linux kernel does not support ipsec as an interface. Also se=
cure interface assume a ipsec policy 4 tupple of {dst-ip-any, src-ip-an=
y, dst-port-any, src-port-any}. Applying this 4 tuple in linux would re=
sult in all traffic matching the ipsec policy. What is needed is a tunn=
el distinguisher. The linux kernel skbuff has fwmark which is used for =
policy based routing (PBR). Linux kernel version 2.6.35 enhanced SPD/SA=
DB to use fwmark as part of the IPsec policy. Strongswan has also intro=
duced support for this kernel feature with version 4.5.0. We can theref=
ore use the fwmark as the distinguisher for tunnel interface. We can al=
so create a light weight tunnel kernel module (vti) to give the notion =
of an interface for rest of the kernel routing system. The tunnel modul=
e does not do any encapsulation/decapsulation. The kernel's xfrm module=
s still do the esp encryption/decryption.
>
> Usage:
> ip tunnel add sti15 mode vti remote 12.0.0.1 local 12.0.0.3 ikey 15
> or
> ip link add sti15 type vti key 15 remote 12.0.0.1 local 12.0.0.3
>
> Signed-off-by: Saurabh Mohan<saurabh.mohan@vyatta.com>
> Reviewed-by: Stephen Hemminger<shemminger@vyatta.com>
>
> ---
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
