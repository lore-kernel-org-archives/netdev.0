From: Sridhar Samudrala <sri@us.ibm.com>
Subject: SCTP path mtu support needs some ip layer support.
Date: Wed, 8 Jan 2003 15:04:53 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0301081451110.2281-100000@dyn9-47-18-86.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <jgrimm2@us.ibm.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave, Alexey,

While working on the SCTP path mtu support, i realized that SCTP needs a
mechanism to set/unset IP DF bit on a per-message basis(let ip_queue_xmit()
know that it is OK to fragment this particular skb).

With TCP, when path mtu discovery is on, DF bit is always set and hence
this information can be maintained on a per socket basis in the inet_opt.

But with SCTP, even when path mtu discovery is on, DF bit may need to be
unset and let ip do fragmenation of certain messages which are already
fragmented by sctp based on the old pmtu. Even when SCTP realizes that the
pmtu is lowered, it cannot re-fragment the already fragmented messages that
have TSNs(Transmission Sequence Nos) assigned. These messages may be waiting
in the transmitted list and may need to be retransmitted later.

I can think of 3 ways to solve this problem.

1. Add a new argument to ip_queue_xmit() to pass the value of DF bit.
2. Use the __unused field in skb to pass the value of DF bit.
3. Let SCTP call its own routine that fills in the ip header with the
   appropriate value in the DF bit, but this duplicates most of the code
   in ip_queue_xmit(). Also ip_options_build() needs to be exported.

Which option do you prefer? Or can you suggest any better alternative?

Thanks
Sridhar
