From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Wed, 22 Aug 2012 12:03:26 +0200
Message-ID: <1345629806.5158.933.camel@edumazet-glaptop>
References: <503419D3.1080700@linlab.net>
	 <1345622798.5158.717.camel@edumazet-glaptop> <50349CC5.3050601@linlab.net>
	 <1345625910.5158.793.camel@edumazet-glaptop> <5034A678.3040207@linlab.net>
	 <1345629597.5158.924.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Alex Bergmann <alex@linlab.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345629597.5158.924.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-08-22 at 12:00 +0200, Eric Dumazet wrote:
> On Wed, 2012-08-22 at 11:29 +0200, Alex Bergmann wrote:
> 
> > Actual 6 SYN frames are sent. The initial one and 5 retries.
> > 
> 
> first one had a t0 + 0 delay. How can it count ???
> 
> > The kernel is waiting another 32 seconds for a SYN+ACK and then gives 
> > the ETIMEDOUT back to userspace.
> > 
> > Do you mean that we have to send another SYN packet after the 3 minutes?
> > 
> 
> First SYN is not a retransmit
> 
> R2 = time_of_last_SYN - time_of_initial_SYN (t0) = 31
> 
> If you read RFC it states :
> 
> "In particular, R2 for a SYN segment MUST
>  be set large enough to provide retransmission of the segment
>  for at least 3 minutes."
> 
> 
> That means that the last _retransmit_ MUST happen after 180 seconds.
> 
> And not :
> 
> Send all the restransmits at t0 + 1, then wait 180 seconds before giving
> connect() a timeout indication.
> 
> 

Therefore, the minimal connect() timeout should be : 180 + 100 seconds

(allowing 100 seconds for the SYNACKs sent in answer of the very last
retransmit to come back)

(100 seconds is the R2 for non SYN frames)

RFC quote : The value of R2 SHOULD
            correspond to at least 100 seconds. 
