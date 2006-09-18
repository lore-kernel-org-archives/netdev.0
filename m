From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 19 Sep 2006 01:03:21 +0400
Message-ID: <20060918210321.GA4780@ms2.inr.ac.ru>
References: <4492D5D3.4000303@atmos.washington.edu> <200609181754.37623.ak@suse.de> <20060918162847.GA4863@ms2.inr.ac.ru> <200609181850.22851.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vladimir B. Savkin" <master@sectorb.msk.ru>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Harry Edmon <harry@atmos.washington.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751088AbWIRVDd@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200609181850.22851.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> But that never happens right? 

Right.

Well, not right. It happens. Simply because you get packet
with newer timestamp after previous handler saw this packet
and did some actions. I just do not see any bad consequences.


> And do you have some other prefered way to solve this? Even if the timer
> was fast it would be still good to avoid it in the fast path when DHCPD
> is running.

No. The way, which you suggested, seems to be the best.


1. It even does not disable possibility to record timestamp inside
   driver, which Alan was afraid of. The sequence is:

	if (!skb->tstamp.off_sec)
                net_timestamp(skb);

2. Maybe, netif_rx() should continue to get timestamp in netif_rx().

3. NAPI already introduced almost the same inaccuracy. And it is really
   silly to waste time getting timestamp in netif_receive_skb() a few
   moments before the packet is delivered to a socket.

4. ...but clock source, which takes one of top lines in profiles
   must be repaired yet. :-)

Alexey
