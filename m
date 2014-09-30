From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Philosophical question:  Is a UDP multicast datagram for which
 there is no socket match a drop or an ignore?
Date: Tue, 30 Sep 2014 16:23:18 -0700
Message-ID: <1412119398.16704.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <542B3831.5030701@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:61164 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaI3XXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 19:23:20 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so3691171pdi.33
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 16:23:19 -0700 (PDT)
In-Reply-To: <542B3831.5030701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 16:09 -0700, Rick Jones wrote:
> I've been looking at some additional perf <mutter> -e skb_kfree_skb 
> results, this time with a laptop connected to a corporate network with a 
> large number of Windows systems sending out what they are wont to 
> send...  The laptop is just sitting there no active netperfs or anything :)
> 
> I see profile hits for __udp4_lib_mcast_deliver() which has a 
> kfree_skb() call which will happen if either there were no sockets 
> found, or if an integral multiple of ARRAY_SIZE(stack) sockets are 
> found.  I'm assuming the latter is exceedingly rare.
> 
> Anywho, the philosophical question - is such a situation a drop 
> (indicating the existing kfree_skb()), or is it an ignore (indicating a 
> consume_skb())?  Should there be a statistic incremented for either of 
> those?

I guess we lack a UDP_MIB_NOPORTS increase here.
