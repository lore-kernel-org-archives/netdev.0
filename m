From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: [ofa-general] RE: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 11:48:45 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903C0821A@orsmsx414.amr.corp.intel.com>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>	<1191886845.4373.138.camel@localhost>	<470AD5D7.1070000@garzik.org>
	<20071008.184126.124062865.davem@davemloft.net>
	<470AE373.9020207@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, hadi@cyberus.ca, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, shemminger@linux-foundation.org, kaber@trash.net
To: "Jeff Garzik" <jeff@garzik.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <470AE373.9020207@garzik.org>
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

> IMO the net driver really should provide a hint as to what it wants.
>=20
> 8139cp and tg3 would probably prefer multiple TX queue=20
> behavior to match silicon behavior -- strict prio.

If I understand what you just said, I disagree.  If your hardware is
running strict prio, you don't want to enforce strict prio in the qdisc
layer; performing two layers of QoS is excessive, and may lead to
results you don't want.  The reason I added the DRR qdisc is for the Si
that has its own queueing strategy that is not RR.  For Si that
implements RR (like e1000), you can either use the DRR qdisc, or if you
want to prioritize your flows, use PRIO.

-PJ Waskiewicz
peter.p.waskiewicz.jr@intel.com
