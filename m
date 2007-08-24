From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Fri, 24 Aug 2007 08:14:16 -0400
Message-ID: <1187957657.4255.35.camel@localhost>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>
	<20070821.212229.82050253.davem@davemloft.net>
	<46CC6DD1.5020105@hp.com>
	<20070822.132145.90824527.davem@davemloft.net>
	<1187906650.4279.16.camel@localhost>
	<1187907903.4279.28.camel@localhost> <46CE0BA1.60206@hp.com>
	<20070823231820.2ae52cc0.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com, kaber@trash.net,
	jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, sri@us.ibm.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070823231820.2ae52cc0.billfink@mindspring.com>
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

On Thu, 2007-23-08 at 23:18 -0400, Bill Fink wrote:

[..]
> Here you can see there is a major difference in the TX CPU utilization
> (99 % with TSO disabled versus only 39 % with TSO enabled), although
> the TSO disabled case was able to squeeze out a little extra performance
> from its extra CPU utilization.  

Good stuff. What kind of machine? SMP?
Seems the receive side of the sender is also consuming a lot more cpu
i suspect because receiver is generating a lot more ACKs with TSO.
Does the choice of the tcp congestion control algorithm affect results?
it would be interesting to see both MTUs with either TCP BIC vs good old
reno on sender (probably without changing what the receiver does). BIC
seems to be the default lately.

> Interestingly, with TSO enabled, the
> receiver actually consumed more CPU than with TSO disabled, 

I would suspect the fact that a lot more packets making it into the
receiver for TSO contributes.

> so I guess
> the receiver CPU saturation in that case (99 %) was what restricted
> its performance somewhat (this was consistent across a few test runs).

Unfortunately the receiver plays a big role in such tests - if it is
bottlenecked then you are not really testing the limits of the
transmitter. 

cheers,
jamal
