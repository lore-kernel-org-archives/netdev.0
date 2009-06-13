From: Anders Eriksson <aeriksson@fastmail.fm>
Subject: Re: [PATCH] r8169: do not bring device down when suspending
Date: Sat, 13 Jun 2009 16:15:16 +0200
Message-ID: <20090613141516.2D1B833C0AC@tippex.mynet.homeunix.org>
References: <20090611204850.GA26691@electric-eye.fr.zoreil.com> <20090611.172257.90040273.davem@davemloft.net> <20090612225029.GA29331@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edward_hsu@realtek.com.tw
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch-smtp01.sth.basefarm.net ([80.76.149.212]:42450 "EHLO
	ch-smtp01.sth.basefarm.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751961AbZFMOPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 10:15:39 -0400
In-reply-to: <20090612225029.GA29331@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


romieu@fr.zoreil.com said:
> If it is easier for you, you can try against 2.6.30 the patch at 
> http://userweb.kernel.org/~romieu/r8169/2.6.30/20090612-r8169-test.patch 

tested, and it does wake up on broadcasted and unicasted UDP magic packet, but
not any other kinds of packets. More specifically:

(Magic payload, UDP, IP dest link broadcast, eth dest broadcast) ->
wakes up on 'g' and 'b'

(Magic payload, UDP, IP dest unicast, eth dest unicast) ->
wakes up on 'g' and 'b'

(arp: eth broadcast) ->
does NOT wake up on 'b' as expected

Hmmm, maybe 'b' stands for IP broadcast and not eth broadcast? Let's see:
(ping broadcast: icmp,  IP dest broadcast, eth dest broadcast) ->
does NOT wake up on 'b'.

As best I can tell, the patch fixes the g case, but something's still broken 
for the other cases the device claims to support ('pumb').

-Anders


