From: "Xiaoliang \(David\) Wei" <weixl@caltech.edu>
Subject: Re: A question on RTT estimation of SACKed packet.
Date: Thu, 29 Aug 2002 15:19:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <028501c24faa$18693d60$f1fa010a@weixl>
References: <200208291901.XAA27022@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Thanks, Alexey.
> >     2. When a packet was SACKed but not retransmitted, the linux also
> > calculate the seq_rtt from it when there is no unSACKed packet in the
queue.
>
> It is not used. When a segment fills a hole, tcp uses skb->when of the
segment
> which _filled_ the hole. See?

Yes, this is exactly my question: When this segment fills a hole, it may be
SACKed before.
If it's SACKed before, that means its "round trip" had already finished
before this ACK came-- Now it's filling the hole just because some strange
things (such as ack loss) happened. So, I don't think we should use its
skb->when to estimate RTT. But in Linux, such a packet (SACKed) may still
provide RTT estimation.

>
> What's about using SACKs to give additional feed to rtt estimator,
> even when ACK is duplicate, it is intersting idea, I even read about
> this somewhere. But we do not use this.
Actually, I am going to do that: Can I get a safe RTT estimation from SACK,
when the SACKed packet (in rtx queue) is never SACKed or Retransmitted?

-David
