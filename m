From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Re: WAN: new PPP code for generic HDLC
Date: Wed, 12 Mar 2008 21:10:31 +0100
Message-ID: <m33aqvsnyg.fsf@maximus.localdomain>
References: <m3prtzsszg.fsf@maximus.localdomain>
	<m3lk4nsskh.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0803122032410.14822@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:48882 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbYCLUKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2008 16:10:36 -0400
In-Reply-To: <Pine.LNX.4.64.0803122032410.14822@fbirervta.pbzchgretzou.qr> (Jan Engelhardt's message of "Wed\, 12 Mar 2008 20\:38\:01 +0100 \(CET\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt <jengelh@computergmbh.de> writes:

>>+	/* LCP only */
>>+	if (pid == PID_LCP)
>>+		switch (cp->code) {
>>+		case LCP_PROTO_REJ:
>>+			pid = ntohs(*(__be16*)skb->data);
>
> What if skb->data happens to be unaligned (can that even happen?)

It can't if the hdlc header is 32-bit aligned... however, I can now
see the above is buggy, skb->data doesn't point to the protocol
field. Unused code paths :-(

> -static const char *code_names[CP_CODES] = {"0", "ConfReq", "ConfAck",
> +static const char *const code_names[] = {"0", "ConfReq", "ConfAck",
>  					   "ConfNak", "ConfRej", "TermReq",
>  					   "TermAck", "CodeRej", "ProtoRej",
>  					   "EchoReq", "EchoReply", "Discard"};

The explicit sizes are there as a prevention.
Thanks.
-- 
Krzysztof Halasa
