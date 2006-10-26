From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Wed, 25 Oct 2006 20:17:04 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B54EF@dhost002-46.dex002.intermedia.net>
References: <45401435.3080407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:27822 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1422886AbWJZDQu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 23:16:50 -0400
Content-class: urn:content-classes:message
In-Reply-To: <45401435.3080407@trash.net>
To: "Patrick McHardy" <kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Wi-Fi alliance's test plans for their WMM specification are written
assuming you use certain specific DSCP values. Since WMM is the only QoS
mechanism that is widely used with 802.11 I followed the WMM values in
the default 802.11 qdisc implementation. Most windows 802.11 drivers do
the same thing.

Simon
 

-----Original Message-----
From: Patrick McHardy [mailto:kaber@trash.net] 
Sent: Wednesday, October 25, 2006 6:50 PM
To: Simon Barber
Cc: David Kimdon; netdev@vger.kernel.org; John W. Linville; Jiri Benc
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than
d80211-specific qdisc

Simon Barber wrote:
> Pfifo_fast does not make sense because the 802.11 qdisc already 
> categorizes the frames based on DSCP. The better thing would be to 
> extract the pfifo qdisc so that it does not require NET_SCHED, but 
> this is more work.

It wouldn't really hurt though since all frames queued to a band already
have the same priority, so pfifo_fast behaves similar to fifo.

BTW, is there a specific reason for using DSCP? Normally Linux uses
rt_tos2priority and prio2band for determining a priority for IP packets.
I don't want to argue that one is better than the other, but there is
some value in keeping things consistent ..

