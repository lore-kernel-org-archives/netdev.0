From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] TCP and batching WAS(Re: [PATCH 00/10] Implement
	batching skb API
Date: Sat, 21 Jul 2007 09:46:19 -0400
Message-ID: <1185025579.5192.68.camel@localhost>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
	<20070720081848.7cc652fb@oldman>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, kaber@trash.net, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, sri@us.ibm.com, jagana@us.ibm.com,
	davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720081848.7cc652fb@oldman>
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

On Fri, 2007-20-07 at 08:18 +0100, Stephen Hemminger wrote:

> You may see worse performance with batching in the real world when
> running over WAN's.  Like TSO, batching will generate back to back packet
> trains that are subject to multi-packet synchronized loss. 

Has someone done any study on TSO effect? Doesnt ECN with a RED router
help on something like this?
I find it suprising that a single flow doing TSO would overwhelm a
routers buffer. I actually think the value of batching as far as TCP is
concerned is propotional to the number of flows. i.e the more flows you
have the more batching you will end up doing. And if TCPs fairness is
the legend talk it has been made to be, then i dont see this as
problematic.

BTW, something i noticed regards to GSO when testing batching:
For TCP packets slightly above MDU (upto 2K), GSO gives worse
performance than non-GSO. Actually has nothing to do with batching,
rather it works the same way with or without batching changes.

Another oddity:
Looking at the flow rate from a purely packets/second (I know thats a
router centric view, but i found it strange nevertheless) - you see that
as packet size goes up, the pps also goes up. I tried mucking around
with nagle etc, but saw no observable changes. Any insight?
My expectation was that the pps would stay at least the same or get
better with smaller packets (assuming theres less data to push around).

cheers,
jamal
