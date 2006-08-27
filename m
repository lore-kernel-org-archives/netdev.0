From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH 0/7] [DCCP]: Fixes and enhancements
Date: Sun, 27 Aug 2006 15:46:58 +1200
Message-ID: <5640c7e00608262046x598d873cr7a4bcd2df971dac0@mail.gmail.com>
References: <200608241516.34448.ian.mcdonald@jandi.co.nz>
	 <20060826.190851.74747699.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: a.bittau@cs.ucl.ac.uk, arnaldo.melo@gmail.com,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-f131.google.com ([64.233.184.131]:31318 "EHLO
	wr-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1751184AbWH0Dq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 23:46:59 -0400
Received: by wr-out-f131.google.com with SMTP id 20so85382wra
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2006 20:46:59 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060826.190851.74747699.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/27/06, David Miller <davem@davemloft.net> wrote:
> >
> > I would love 3, 4, 5 to go into 2.6.18 as these resolve long standing CCID3
> > issues that have been in the DCCP tree since inception and have caught a
> > number of people.
>
> Ok, I'll toss 1-5 into 2.6.18

Thanks for that. Are 6 and 7 going into 2.6.19 or do you want Arnaldo
to have a bit more of a look? 6 in particular is trivial.
>
> One thing I don't understand is this description from patch 5:
>
> --------------------
> This gives a theoretical speed of 71.9 Kbits/s. I measured across three
> runs with this patch set and got 70.1 Kbits/s. Without this patchset the
> average was 232 Kbits/s which means Linux can't be used for CCID3 research
> properly.
> --------------------
>
> Decreasing the transfer rate is desirable?  I read this as saying
> this "fix" drops the transfer rate down from 232Kb/sec to
> 70.1Kb/sec.  What's going on here?

DCCP CCID3 (RFC 4342) uses TFRC (RFC 3448) to calculate the desired
rate to send at based on feedback from the receiver. The reason for
this is that TFRC is not ACK/Window based to control rate and TFRC
calculates a rate so that the flow is "fair" when competing with TCP.
TFRC is designed to be smoother than TCP at dealing with loss - more
sine wave than saw tooth.

The calculation is based on the work Padhye et al did in this paper -
http://citeseer.ist.psu.edu/padhye98modeling.html

As it turns out this is based on TCP Reno at that time and modern TCP
variants are more efficient when dealing with loss as can be verified
through iperf but we should implement what the RFC says.

Basically the implementation in the DCCP code was buggy and was
transmitting too fast so I have made it conform to the RFC much
closer.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
