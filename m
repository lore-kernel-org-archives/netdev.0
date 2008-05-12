From: "Andy Johnson" <johnsonzjo@gmail.com>
Subject: Re: A question about setting the net device for multicast forwarding in IPv4 and in IPv6
Date: Mon, 12 May 2008 11:57:05 +0300
Message-ID: <147a89290805120157y7af3ad9bge6ce23332b9040ca@mail.gmail.com>
References: <31436f4a0805060638o2f97e3d7v8355fb678454da47@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"=?UTF-8?Q?YOSHIFUJI_Hideaki_/_=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?="
	<yoshfuji@linux-ipv6.org>
To: "David Shwatrz" <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:26997 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754778AbYELI5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 04:57:06 -0400
Received: by rv-out-0506.google.com with SMTP id l9so2554113rvb.1
        for <netdev@vger.kernel.org>; Mon, 12 May 2008 01:57:05 -0700 (PDT)
In-Reply-To: <31436f4a0805060638o2f97e3d7v8355fb678454da47@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, David,

  - I wanted to note that there is one more difference I had noted
between IPv4 and IPv6
regarding multicast forwarding:

  - In IPv4, mc_forwarding is disabled by default (the value is 0). If
you will try to change it thus:
echo "1" >  /proc/sys/net/ipv4/conf/eth0/mc_forwarding
you will get:

/proc/sys/net/ipv4/conf/eth0/mc_forwarding: Permission denied.

ls -al /proc/sys/net/ipv4/conf/eth0/mc_forwarding
will show:
-r--r--r-- 1 root root 0 ...

But:
  chmod 666  /proc/sys/net/ipv4/conf/eth0/mc_forwarding
gives:

chmod 666  /proc/sys/net/ipv4/conf/eth0/mc_forwarding
chmod: changing permissions of
`/proc/sys/net/ipv4/conf/eth0/mc_forwarding': Operation not permitted

User space daemons (like xorp) will set
/proc/sys/net/ipv4/conf/all/mc_forwarding  to 1
(because they call setsockopt with MRT_INIT, which calls
IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)++;
in ip_mroute_setsockopt(), as you mentioned.

 In IPV6, this does not happen.

In IPV6, Multicast Routing is also disabled by default.

**But **

echo "1" >  /proc/sys/net/ipv6/conf/all/mc_forwarding
**does** work and **does not** give an error (as in IPV4).

I wonder what is the reason for it ? Or maybe it should be changed to
have the same behaviour both in IPV6 and IPV4?

Regards,
Andy






On Tue, May 6, 2008 at 4:38 PM, David Shwatrz <dshwatrz@gmail.com> wrote:
> Hi,
>  I had noticed that in IPV4 we set the net device for multicast
> forwarding in case
> it is not already configured so, when the user space app calls
> setsockopt() with MRT_INIT;
> this is done by calling IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)++;
> in ip_mroute_setsockopt(); (net/ipv4/ipmr.c).
>
> On the other hand, the parallel method in IPv6 does **not** performs
> such action, as can be seen
> from ip6_mroute_setsockopt() in net/ipv6/ip6mr.c.
>
> My question is : is there any special for it to be so? (In case it
> should be also in IPv6, I will happy to send such a patch).
>
> Best Regards,
> DS
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
