From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Wed, 7 Sep 2005 16:45:03 +0200
Message-ID: <17182.64751.340488.996748@robur.slu.se>
References: <20050815213855.GA17832@netnation.com>
	<43014E27.1070104@cosmosbay.com>
	<20050823190852.GA20794@netnation.com>
	<17163.32645.202453.145416@robur.slu.se>
	<20050824000158.GA8137@netnation.com>
	<20050825181111.GB14336@netnation.com>
	<20050825200543.GA6612@yakov.inr.ac.ru>
	<20050825212211.GA23384@netnation.com>
	<20050826115520.GA12351@yakov.inr.ac.ru>
	<17167.29239.469711.847951@robur.slu.se>
	<20050906235700.GA31820@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20050906235700.GA31820@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Simon Kirby writes:

 > Woot!
 > 
 > Yes, this is the difference.  With the patch applied (ajust directly
 > freeing the dst_entry), everything balances easily, there are no
 > overflows, and the result of rt_may_expire() looks very reasonable.
 > (Yay!)
 >
 > So, this seems to be the culprit.  Is NAPI supposed to allow the
 > queued bh to run or should we just not be queuing this?

 Packet processing happens in RX_SOFIRQ. NAPI or non-NAPI is no difference
 with RCU deferred delete this should happen by the RCU-tasklet when 
 tasklets are run after the real SOFTIRQ's.

 There is a limit for RCU work... maxbatch it's set to 10  you could back 
 out the patch and try increase it 1000/10000 so we know this not prevent 
 the freeing of entries. 

 module_param(maxbatch, int, 0);  /* rcupdate.c */
 
 Also RCU clearly states that is should be used in read-mostly situations
 rDoS is outside this scope. Anyway it would be interesting to understand 
 what's going on.

 Cheers.
						--ro

 
