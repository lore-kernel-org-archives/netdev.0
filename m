From: Andi Kleen <ak@suse.de>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Mon, 13 Jan 2003 22:07:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030113210708.GA328@wotan.suse.de>
References: <3E1CCD72.6020100@us.ibm.com> <200301132048.XAA09194@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, Jon Grimm <jgrimm2@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200301132048.XAA09194@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Support of pmtu discovery as described in rfc means possibility of semantic
> fragmentation to retransmit any data bits. If SCTP is not ablet to do this,
> then you should not support pmtu discovery at all like most of people make
> for UDP or to follow UDP pattern, fragmenting frames when their size exceeds
> mtu. It is not necessary to cripple ip_queue_xmit calling conventions
> to make this, just add a flag to socket to clear DF on oversized
> frames.

Some recent incidents have shown that ip fragmentation/defragmention
at gigabit speed is rather worthless. The reason is that it has no PAWS
and the 16bit ipid can wrap many times in the standard reassembly
timeout, leading to lots of misassembled packets on a busy network.
Mostly that can be catched by computing the transport layer
checksum, but often enough a misassembled packet can slip through.
While in SCTP it may work a bit better because it supports stronger 
checksums (but only optionally afaik) it is still too dangerous.
So in short clearing DF is near always a bug these days.

-Andi
