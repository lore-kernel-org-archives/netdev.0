From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Wed, 08 Aug 2007 18:40:32 -0400
Message-ID: <1186612832.5152.34.camel@localhost>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
	<20070808.034900.85820906.davem@davemloft.net>
	<20070808134247.GA9942@gondor.apana.org.au>
	<1186586075.5155.27.camel@localhost> <20070808215501.4825d74b@oldman>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com,
	Herbert Xu <herbert@gondor.apana.org.au>, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, mcarlson@broadcom.com,
	David Miller <davem@davemloft.net>, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, netdev@vger.kernel.org, kaber@trash.net, sri@us.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070808215501.4825d74b@oldman>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-08-08 at 21:55 +0100, Stephen Hemminger wrote:

> > pktgen shows a clear win if you test the driver path - which is what you
> > should test because thats where the batching changes are. 
> > Using TCP or UDP adds other variables[1] that need to be isolated first
> > in order to quantify the effect of batching. 
> > For throughput and CPU utilization, the benefit will be clear when there
> > are a lot more flows. 
> 
> Optimizing for pktgen is a mistake for most users. 

There is no "optimization for pktgen". 

If you are improving the tx path, the first step is to test that you can
show the tx path improved. pktgen happens to be the best test suite for
that because it talks to the driver and exercises the changes.
i.e if one cant show that exercising the direct path demonstrates
improvements you probably wont be able to show batching improves TCP -
but i dont even wanna swear by that. 
Does that make sense?

> Please show something
> useful like router forwarding, TCP (single and multi flow) and/or better
> yet application benchmark improvement.

Absolutely, but first things first. Analysis of why something improves
is extremely important, just saying "TCP throughput improved" is not
interesting and lazy. 
To be scientific, it is important to isolate variables first in order to
come up with meaningful results that can be analysed. 
To make a point, I have noticed extremely different results between TCP
BIC vs reno with batching. So congestion control as a variable is
important. 

cheers,
jamal
