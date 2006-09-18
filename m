From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 18 Sep 2006 19:38:22 +0400
Message-ID: <20060918153822.GA805@ms2.inr.ac.ru>
References: <4492D5D3.4000303@atmos.washington.edu> <44948EF6.1060201@atmos.washington.edu> <Pine.LNX.4.61.0606191638550.23553@ask.diku.dk> <200606191724.31305.ak@suse.de> <20060916120845.GA18912@tentacle.sectorb.msk.ru> <p73k6414lnp.fsf@verdi.suse.de> <20060918090330.GA9850@tentacle.sectorb.msk.ru> <p73eju94htu.fsf@verdi.suse.de> <20060918102918.GA23261@tentacle.sectorb.msk.ru> <p73ac4x4doi.fsf@verdi.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vladimir B. Savkin" <master@sectorb.msk.ru>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Harry Edmon <harry@atmos.washington.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:51840 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751787AbWIRPjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 11:39:31 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <p73ac4x4doi.fsf@verdi.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> For netdev: I'm more and more thinking we should just avoid the problem
> completely and switch to "true end2end" timestamps. This means don't
> time stamp when a packet is received, but only when it is delivered
> to a socket.

This will work.

>From viewpoint of existing uses of timestamp by packet socket
this time is not worse. The only danger is violation of casuality
(when forwarded packet or reply packet gets timestamp earlier than
original packet). This pathology was main reason why timestamp
is recorded early, before packet is demultiplexed in netif_receive_skb().
But it is not a practical problem: delivery to packet/raw sockets
is occasionally placed _before_ delivery to real protocol handlers.


> handler runs. Then the problem above would completely disappear. 

Well, not completely. Too slow clock source remains too slow clock source.
If it is so slow, that it results in "performance degradation", it just
should not be used at all, even such pariah as tcpdump wants to be fast.

Actually, I have a question. Why the subject is
"Network performance degradation from 2.6.11.12 to 2.6.16.20"?
I do not see beginning of the thread and cannot guess
why clock source degraded. :-)

Alexey
