From: Peter Bieringer <pb@bieringer.de>
Subject: Re: ICMPv6 ratelimiting, which /proc-settings related?
Date: Tue, 16 Jul 2002 09:07:46 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <14790000.1026803266@localhost>
References: <17380000.1026547066@localhost>
 <20020715.024401.17983126.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" <yoshfuji@wide.ad.jp>
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20020715.024401.17983126.yoshfuji@wide.ad.jp>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org



--On Monday, July 15, 2002 02:44:01 AM +0900 "YOSHIFUJI Hideaki /
=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" <yoshfuji@wide.ad.jp> wrote:

> In article <17380000.1026547066@localhost> (at Sat, 13 Jul 2002
> 09:57:46 +0200), Peter Bieringer <pb@bieringer.de> says:
> 
>> extending my IPv6-howto with information about the /proc-FS I found
>> that there is no setting for ICMPv6 rate limiting.
> 
> icmpv6_xrlim_allow() controls rate limiting.
> 
> A variable named sysctl_icmpv6_time lives in net/ipv6/icmp.c, but
> sysctl does not exist in fact...

Oh, I found:

# grep icmpv6_time *
icmp.c:int sysctl_icmpv6_time = 1*HZ;
icmp.c:         int tmo = sysctl_icmpv6_time;


> Is introducing /proc/sys/net/ipv6/icmp/all/icmpv6_time reasonable?

Is HZ completly arch independed? Afair, it was CPU depended (like
grep HZ include/asm/param.h) shows.

Mho: Better name:

/proc/sys/net/ipv6/icmp/all/icmpv6_rate

I would suggest use of unit 1/s and run conversion internally.
Therfore
1 -> 1/s
10 -> 10/s
100 -> 100/s
0.1 -> 1/10s

        Peter
