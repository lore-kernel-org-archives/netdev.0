From: Rick Jones <rick.jones2@hp.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Thu, 27 Jan 2005 16:10:46 -0800
Message-ID: <41F98306.6070804@hp.com>
References: <41F1516D.5010101@hp.com> <200501211358.53783.jdmason@us.ibm.com>	<41F163AD.5070400@hp.com>	<20050121124441.76cbbfb9.davem@davemloft.net>	<41F17B7E.2020002@hp.com>	<20050121141820.7d59a2d1.davem@davemloft.net>	<41F186A8.9030805@hp.com>	<20050121204948.034b2510.davem@davemloft.net>	<41F55B93.6040603@hp.com> <20050124124353.2f760e1a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050124124353.2f760e1a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Becuase we disable TSO on any packet loss whatsoever, we can predict
> exactly what the CWND will be at the time a packet is sent.
> 
> I've been quiet the past few days, but this is the kind of implementation
> I've been thinking of.
> 
> When we take away that invariant, which we do want to do, we'll need
> to tweak how this works.

Having thought about the topic a bit, it now seems that there were two benchmark 
run-rule compliance problems with TSO in 2.6.  One is the slow-start stuff that 
has been worked-on and may get a couple additional tweaks (hopefully).

The other relates to the business of disabling TSO on a connection upon packet loss.

While the benchmark(s) that spring to mind are run over generally lossless LANs, 
the intent is that the solution be suitable for an Internet connected system 
(yes, someone could probably punch big gaping holes there...).  Internet 
connected systems experience non-trivial packet loss rates and so if TSO 
disabled upon packet loss it means a given benchmark result using TSO deviates 
even more from reality than one without TSO.

I suspect it would be found to be a benchmark special and disallowed.

I do not know what other stacks do with their TSO implementation to know if they 
are in a similar state.  It would be good to know if anyone out there knows and 
would be willing to say.

rick jones
