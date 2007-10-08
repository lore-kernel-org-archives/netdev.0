From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: parallel networking
Date: Mon, 08 Oct 2007 14:11:54 -0700 (PDT)
Message-ID: <20071008.141154.107706003.davem@davemloft.net>
References: <20071007.215124.85709188.davem@davemloft.net>
	<1191850490.4352.41.camel@localhost> <470A3D24.3050803@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, Robert.Olsson@data.slu.se, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, peter.p.waskiewicz.jr@intel.com,
	shemminger@linux-foundation.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, rdreier@cisco.com,
	general@lists.openfabrics.org, mingo@elte.hu, sri@us.ibm.com,
	jagana@us.ibm.com, hadi@cyberus.ca, mchan@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, kaber@trash.net
To: jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <470A3D24.3050803@garzik.org>
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

From: Jeff Garzik <jeff@garzik.org>
Date: Mon, 08 Oct 2007 10:22:28 -0400

> In terms of overall parallelization, both for TX as well as RX, my gut 
> feeling is that we want to move towards an MSI-X, multi-core friendly 
> model where packets are LIKELY to be sent and received by the same set 
> of [cpus | cores | packages | nodes] that the [userland] processes 
> dealing with the data.

The problem is that the packet schedulers want global guarantees
on packet ordering, not flow centric ones.

That is the issue Jamal is concerned about.

The more I think about it, the more inevitable it seems that we really
might need multiple qdiscs, one for each TX queue, to pull this full
parallelization off.

But the semantics of that don't smell so nice either.  If the user
attaches a new qdisc to "ethN", does it go to all the TX queues, or
what?

All of the traffic shaping technology deals with the device as a unary
object.  It doesn't fit to multi-queue at all.
