From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] enic: fix rx skb checksum
Date: Fri, 19 Dec 2014 12:07:57 +0100
Message-ID: <20141219120757.106c02d4@griffin>
References: <1418898522-13588-1-git-send-email-_govind@gmx.com>
	<1418920017.9773.80.camel@edumazet-glaptop2.roam.corp.google.com>
	<17951.1418924367@famine>
	<20141219110732.53264ef8@griffin>
	<alpine.LNX.2.03.1412191548001.2860@ws.cisco>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com,
	Stefan Assmann <sassmann@redhat.com>
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023AbaLSLIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 06:08:13 -0500
In-Reply-To: <alpine.LNX.2.03.1412191548001.2860@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Dec 2014 16:22:34 +0530 (IST), Govindarajulu Varadarajan wrote:
> Hardware returns 0xffff for non tcp/udp packets.

That explains that I saw that with ICMP packets.

> For tcp/udp packet it returns
> pseudo checksum. Not the _whole_ pkt checksum.

I see. I didn't get this from your patch, although you wrote it there,
sorry. And I didn't dig that deep while debugging, I was satisfied with
seeing 0xffff for the packets that caused problems :-)

> Dec 18 11:13:18 a163 kernel: enic: saddr=96d8690a, daddr=a3ba6a0a, length=40, proto=6
> Dec 18 11:13:18 a163 kernel: enic: hw_checksum = c457, pseudo_checksum_32=3a930115, pseudo_checksum_fold=c457
> 
> Dec 18 11:13:18 a163 kernel: enic: saddr=a37410a, daddr=a3ba6a0a, length=32, proto=6
> Dec 18 11:13:18 a163 kernel: enic: hw_checksum = 80f9, pseudo_checksum_32=adf1d114, pseudo_checksum_fold=80f9
> 
> Dec 18 11:13:18 a163 kernel: enic: saddr=a37410a, daddr=a3ba6a0a, length=32, proto=6
> Dec 18 11:13:18 a163 kernel: enic: hw_checksum = 80f9, pseudo_checksum_32=adf1d114, pseudo_checksum_fold=80f9
> 
> Clearly hw is returning folded pseudo checksum.

Indeed.

> > I have no idea whether the hardware verified the checksum for the
> > 0xffff case and is just not returning the checksum or whether such
> > packets come completely unverified.
> 
> Yes, hardware verifies the checksum and sets tcp_udp_csum_ok flag to 1.
> If pkt verification fails or pkt is not tcp/udp, tcp_udp_csum_ok is 0. And we
> send the pkt to stack with CHECKSUM_NONE.

Thanks for the confirmation.

> Driver should use CHECKSUM_COMPLETE only if it can produce _whole_ pkt checksum.
> as described in include/linux/skbuff.h:75

Sure. I just misunderstood what the hardware provides.

> I am trying to fix "Do not set CHECKSUM_COMPLETE, when driver does not have
> checksum of whole pkt."
> 
> Is my understanding correct?

With the information you've just written (thanks for your patience),
I think your patch is correct.

Thanks a lot!

 Jiri

-- 
Jiri Benc
