From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 0/10 REV5] Implement skb batching and
 support in IPoIB/E1000
Date: Sun, 16 Sep 2007 19:25:02 -0700 (PDT)
Message-ID: <20070916.192502.123919711.davem@davemloft.net>
References: <1189988958.4230.55.camel@localhost>
	<20070916.180232.101592975.davem@davemloft.net>
	<1189995261.4230.61.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1189995261.4230.61.camel@localhost>
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

From: jamal <hadi@cyberus.ca>
Date: Sun, 16 Sep 2007 22:14:21 -0400

> I still think this work - despite my vested interest - needs more
> scrutiny from a performance perspective.

Absolutely.

There are tertiary issues I'm personally interested in, for example
how well this stuff works when we enable software GSO on a non-TSO
capable card.

In such a case the GSO segment should be split right before we hit the
driver and then all the sub-segments of the original GSO frame batched
in one shot down to the device driver.

In this way you'll get a large chunk of the benefit of TSO without
explicit hardware support for the feature.

There are several cards (some even 10GB) that will benefit immensely
from this.
