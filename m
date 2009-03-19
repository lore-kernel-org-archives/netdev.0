From: Oliver Zheng <mailinglists+netdev@oliverzheng.com>
Subject: Re: [PATCH net-next-2.6] Re: TCP/IP stack interpretation of
	acceptable packet
Date: Wed, 18 Mar 2009 18:47:35 -0700
Message-ID: <20090319014734.GB26783@oliveoil.chn.comcast.net>
References: <2ff60cd60902241459q1de39054lb3dc5233f13b69c3@mail.gmail.com> <1237423493.32009.31.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andi Kleen <andi@firstfloor.org>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:25330 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbZCSBmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:42:42 -0400
Received: by rv-out-0506.google.com with SMTP id f9so297560rvb.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 18:42:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1237423493.32009.31.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 12:44:53AM +0000, John Dykstra wrote:
> RFC793 says (Section 3.9) that not only should such segments be
> discarded, but that an ACK should be sent to the peer.  I can't see what
> that accomplishes, and it seems to badly interact with fast
> retransmit--under some conditions with crafted packets you can get the
> two stacks ACKing each other forever.  So I left that out of this patch:

I think part of the original intentions for the response ack is to
generate the "ack storm". In certain cases of tcp hijacking where the
attacker is trying to resynchronize a tcp session after injecting a
packet into the stream, an ack storm raises alerts in intrusion
detection systems. Most of the times, built-in measures reset the tcp
session given an unusual large number of acks (I'm not sure how or if
Linux does this).

This was partially the original reason I was looking into this. I
noticed that Windows does not send an ack back if the received ack has
a higher than expected ack number *and* higher than expected sequence
number. For some well crafted tcp hijacking cases, this increases the
attack success rate substantially.

It's beyond my knowledge of other implications such a response ack would
cause.

Cheers,
Oliver
