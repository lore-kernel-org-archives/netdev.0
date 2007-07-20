From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 00/10] Implement batching skb API
Date: Fri, 20 Jul 2007 13:17:40 +0530
Message-ID: <OF106EAF42.CD1BE35D-ON6525731E.002A5041-6525731E.002AD13B@in.ibm.com>
References: <20070720081848.7cc652fb@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	sri@us.ibm.com, davem@davemloft.net, rdreier@cisco.com
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

Stephen Hemminger <shemminger@linux-foundation.org> wrote on 07/20/2007
12:48:48 PM:

> You may see worse performance with batching in the real world when
> running over WAN's.  Like TSO, batching will generate back to back packet
> trains that are subject to multi-packet synchronized loss. The problem is
that
> intermediate router queues are often close to full, and when a long
string
> of packets arrives back to back only the first ones will get in, the rest
> get dropped.  Normal sends have at least minimal pacing so they are less
> likely do get synchronized drop.

Also forgot to mention in the previous mail, if performance is seen to be
dipping,
batching can be disabled on WAN's by:

echo 0 > /sys/class/net/<dev>/tx_batch_skbs

and use batching on local/site networks in that case.
