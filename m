From: rapier <rapier@psc.edu>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Wed, 17 Dec 2014 12:32:00 -0500
Message-ID: <5491BE10.3000706@psc.edu>
References: <54908FAD.5060500@psc.edu>		<20141216.150354.64901094367530710.davem@davemloft.net>		<54909278.6090806@psc.edu>	 <20141216.151823.2276708539799601894.davem@davemloft.net>	 <54909DD5.5070202@psc.edu> <1418769212.9773.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.70.106]:47502 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbaLQRcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 12:32:05 -0500
In-Reply-To: <1418769212.9773.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/14 5:33 PM, Eric Dumazet wrote:

> There is very little chance web10g ~3000 lines of code are added into
> linux TCP stack, by people who did not submit netdev changes in last
> years.

I do understand this. I went though something similar when submitting 
the hpn-ssh patch set to OpenSSH many years ago. In retrospect we should 
have been submitting subsets of the instruments on a periodic basis over 
the past couple of years.

I also understand the need to be conservative in the approach to 
inclusion of new functionality. No one, least of all my team, wants to 
introduce instability or useless complexity into the stack.

> At Google, we tried the web10g route, but reverted it (today !) in favor
> of tcp_info extensions (ss command from iproute2 can also grab/display
> these), after too many bugs being filled.

I was informed that there was parallel development at Google and the 
decision to move in favor of tcp_info happened not that long ago. I do 
wish Google had shared more of these bug reports with the development 
team so we could have addressed them at the time. That's how things go 
though.

> Researchers love/want to have hundred of metrics. This does not mean
> linux has to provide them natively, unless we can prove it is really
> damn useful.

We agree with that. What we've found is that determining the most 
valuable metrics often depends on the context. Those looking at 
instrumenting connections within a data center are going to be looking 
at different metrics than someone managing flows across a federated set 
of widely distributed data transfer nodes. I'd be more than happy to 
discuss what instruments provide the most value and which are 
superfluous. In fact, I believe this is a critical conversation *if* the 
community feels that more stack instrumentation would be useful.

> Sorry, but someone had to raise some reality concerns.

No need to apologize. Reality, like the Moon, is a harsh mistress.

> tcp_info _is_ extensible, granted you do not try to push 127 new metrics
> in it.

We are more than willing to look in to extending tcp_info. We do think 
our methodology has some value though. One of the things we feel is an 
advantage is that tcp_estats has a method to query the MIB and 
dynamically determine what set of instruments are available. This allows 
for a bit more flexibility in terms of forward/backward compatibility.

Chris
