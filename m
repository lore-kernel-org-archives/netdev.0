From: kuznet@ms2.inr.ac.ru
Subject: Re: A question on RTT estimation of SACKed packet.
Date: Thu, 29 Aug 2002 23:01:11 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200208291901.XAA27022@sex.inr.ac.ru>
References: <037601c24f45$4549fe10$f1fa010a@weixl>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: weixl@caltech.EDU (Xiaoliang \(David\), Wei)
In-Reply-To: <037601c24f45$4549fe10$f1fa010a@weixl> from "Xiaoliang \(David\) Wei" at Aug 29, 2 02:45:00 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>     2. When a packet was SACKed but not retransmitted, the linux also
> calculate the seq_rtt from it when there is no unSACKed packet in the queue.
>      I cannot understand the second situation: The packet was SACKed before,
> that means it arrived the receiver and triggered a SACK sometime before. The
> interval between when packet is sent and when the SACK is received should be
> the RTT for experienced this packet. Even now the packet is ACKed, I don't
> think this ACK is triggered by this packet. Why is it used to calculate the
> RTT?

It is not used. When a segment fills a hole, tcp uses skb->when of the segment
which _filled_ the hole. See?

What's about using SACKs to give additional feed to rtt estimator,
even when ACK is duplicate, it is intersting idea, I even read about
this somewhere. But we do not use this.

Alexey
