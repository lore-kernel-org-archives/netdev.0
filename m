From: kuznet@ms2.inr.ac.ru
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Mon, 13 Jan 2003 23:48:10 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301132048.XAA09194@sex.inr.ac.ru>
References: <3E1CCD72.6020100@us.ibm.com>
Mime-Version: 1.0
Cc: davem@redhat.com, sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgrimm2@us.ibm.com (Jon Grimm)
In-Reply-To: <3E1CCD72.6020100@us.ibm.com> from "Jon Grimm" at Jan 8, 3 07:16:34 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Well, I personally like having the flexibility to do either.  So, we'll 
> take you up on your offer to allow control over DF.

Beware! To all that I can say, clearing DF on some packets compromises
path mtu discovery. If you need to have cleared DF on some packets in a flow,
this means in fact, that path mtu discovery is not supported at protocol level
at all.

So, I would like to ask you to consult SCTP designers. If the thing which
you have said is true this means they desinged a crippled protocol.

Support of pmtu discovery as described in rfc means possibility of semantic
fragmentation to retransmit any data bits. If SCTP is not ablet to do this,
then you should not support pmtu discovery at all like most of people make
for UDP or to follow UDP pattern, fragmenting frames when their size exceeds
mtu. It is not necessary to cripple ip_queue_xmit calling conventions
to make this, just add a flag to socket to clear DF on oversized
frames.

Alexey
