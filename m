From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: TCP retransmission timers, questions
Date: Mon, 01 Dec 2003 10:10:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FCB8415.7060101@us.ibm.com>
References: <010801c3b657$e3093fb0$6501010a@C5043436>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ronnie Sahlberg <ronnie_sahlberg@ozemail.com.au>
In-Reply-To: <010801c3b657$e3093fb0$6501010a@C5043436>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ronnie Sahlberg wrote:

> By looking at the kernel sources it seems that the minimum TCP
> retransmission timeout is hardcoded to 200ms.
> Is this correct?

Yes, that is correct.

> While I understand why it is important to not be too aggressive in
> retransmitting I wounder if it would be possible to get
> and interface in proc where one could "tune" this.

Currently, not unless you edit the kernel header
file yourself and recompile the kernel. Not recommended
for several reasons.

> The reason for this is that in some applications you do have a completely
> private, dedicated network used for one specific application.
> Those networks can be dimensioned so that congestion "should" not occur.
> However, packets are lost from time to time and sometimes packets will be
> lost.
> In those isolated dedicated subnets, with end to end network latency in the
> sub ms range, would it not be useful to be able to allow
> the retransmission timeout to drop down to 5-10ms?

Exactly the scheme I was interested in proposing a while
ago - provide a env for private networks that would allow
more flexible tuning for private nets.

> Do anyone know of any work/research in the area of tcp retransmission
> timeouts for very high bandwidth, low latency networks?
> I have checked both the IETF list of drafts, Sally Floyds pages and google
> but could not find anything.

Not that I could find last year either.

> It seems to me that all research/experimentation in high throughput is for
> high bandwidth high latency links and tuning the slowstart/congestion
> avoidance algorithms.
> What about high throughput, very low latency?  Does nayone know of any
> papers in that area?

I'm doing my own experimentation for this environment -
case study a 3 tiered app with a private network between
the web front end and the database backend. I'm playing
with gigabit but hope to do some 10Gb testing sometime
in the near future. Hope to provide a experimental patch
to play with, but it wont be soon. Mostly January.

We had a thread on this a while ago, and DaveM pointed
out that this was really a research area because the 200ms
timer limit (BSD inherited) played a rather critical role
in all the congestion control, and what its impact might
be if changed on Internet traffic really needed to be
studied/researched.

However, that wouldnt apply to private, non-routable
networks.

> For specific applications, running on completely isolated dedicated
> networks, dimensioned to make congestion unlikely, isolated so it will NEVER
> compete about bandwidth with normal TCPs on the internet,  to me it would
> make sense to allow the retransmission timeout to be allowed to drop
> significantly below 200ms.

Exactly.

> Another question, I think it was RFC2988 (but an not find it again) that
> discussed that a TCP may add an artificial delay in sending the packets
> based on
> the RTT so that when sending an entire window the packets are spaced
> equidistantly across the RTT interval instead of in just one big burst.
> This to prevent the burstinessd of the traffic and make buffer
> overruns/congestion less likely.

I havent seen this help for the most part.

This is helpful only in very selective situations. If youre
studying multiple streams across one network, performance
could be equally hurt/helped. Have you any data on this?

> I have seen indications that w2k/bsd might in some conditions do this.
> Doe Linux do this? my search through the sources came up with nothing.
> Does anyone know whether there are other TCPs that do this?
> As i said I have seen something that looked like that on a BSD stack but it
> could have been related to something else.

Linux doesn't, and the others dont either, to my knowledge,
but I could be wrong, its been a while since I looked at the
other OSs.

hth,

thanks,
Nivedita
