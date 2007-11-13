From: "SANGTAE HA" <sangtae.ha@gmail.com>
Subject: Re: possible bug in tcp_probe
Date: Tue, 13 Nov 2007 09:59:15 -0500
Message-ID: <649aecc70711130659p3040b532jff62c69d81414eef@mail.gmail.com>
References: <20071113112615.GA7491@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Gavin McCullagh" <Gavin.McCullagh@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:30142 "EHLO
	rn-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751963AbXKMO7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 09:59:18 -0500
Received: by rn-out-0102.google.com with SMTP id s46so1992542rnb
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 06:59:16 -0800 (PST)
In-Reply-To: <20071113112615.GA7491@nuim.ie>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gavin,

This is fixed in the current version of tcp_probe by Stephen.  Please
see the below.

commit 662ad4f8efd3ba2ed710d36003f968b500e6f123
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Wed Jul 11 19:43:52 2007 -0700

   [TCP]: tcp probe wraparound handling and other changes

   Switch from formatting messages in probe routine and copying with
   kfifo, to using a small circular queue of information and formatting
   on read.  This avoids wraparound issues with kfifo, and saves one
   copy.

   Also make sure to state correct license, rather than copying off some
   other driver I started with.

   Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
   Signed-off-by: David S. Miller <davem@davemloft.net>

You can copy the current version of tcp_probe to your kernel version
and it should work.
Before this has not been fixed, in my case, I changed kfifo not to put
the data if it doesn't have enough space.
I will send you a patch if you want this.

Regards,
Sangtae

On Nov 13, 2007 6:26 AM, Gavin McCullagh <Gavin.McCullagh@nuim.ie> wrote:
> Hi,
>
> I'm using linux v2.6.22.6 and tcp_probe with a couple of small
> modifications[1].
>
> Even with moderately large numbers of flows (16 on the one machine) and
> increasingly as I monitor more flows than that, I get strange overflow
> problems such as this one:
>
> 74.259589763 192.168.2.1 36988 192.168.3.5 5001 0x679c23dc 0x679bc3b4 18 13 9114624 78 76 10000 0 64
> 74.260590660 192.168.2.1 44261 192.168.3.5 5006 0x573bb3ed 0x573b700d 13 9 5254144 155 127 10000 0 64
> 74.261607478 192.168.2.1 44261 192.168.3.5 5006 0x588.066586741 192.168.2.1 33739 192.168.3.5 5009 0xe26d1767 0xe26cf577 2 3 13090816 443 15818 10000 0 64
> 88.066690797 192.168.2.1 33739 192.168.3.5 5009 0xe26d1767 0xe26cfb1f 3 3 13092864 2365 15818 10000 0 64
> 88.067625714 192.168.2.1 59385 192.168.3.5 5012 0x411c1090 0x411bd258 12 9 14578688 2807 15812 10000 0 64
>
> As you can see the third line has been truncated as well as the next
> roughly 14 seconds of data after which data continues writing as usual.
>
> I don't think my small changes are causing this but perhaps I'm wrong.
> Does anyone know what might be causing the above?
>
> Many thanks for any ideas,
> Gavin
>
> [1] I have slightly modified tcp_probe to print out information for a range
> of ports (instead of one port or all) and to print info from the congestion
> avoidance inet_csk_ca struct.  This adds a couple of extra fields to the
> end.  If either of these are of interest as patches I'll happily submit
> them.
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
