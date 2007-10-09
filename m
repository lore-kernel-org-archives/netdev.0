From: jamal <hadi@cyberus.ca>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 17:56:46 -0400
Message-ID: <1191967006.5324.14.camel@localhost>
References: <p73k5pw44ew.fsf@bingen.suse.de>
	<20071009.134331.35664207.davem@davemloft.net>
	<20071009135340.33e5922c@freepuppy.rosehill>
	<20071009.142235.74385364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, jeff@garzik.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	andi@firstfloor.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, shemminger@linux-foundation.org, kaber@trash.net,
	mchan@broadcom.com, jagana@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009.142235.74385364.davem@davemloft.net>
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


On Tue, 2007-09-10 at 14:22 -0700, David Miller wrote:

> Even if the device has "huge queues" I still think we need a software
> queue for when the hardware one backs up.

It should be fine to just "pretend" the qdisc exists despite it sitting
in the driver and not have s/ware queues at all to avoid all the
challenges that qdiscs bring; 
if the h/ware queues are full because of link pressure etc, you drop. We
drop today when the s/ware queues are full. The driver txmit lock takes
place of the qdisc queue lock etc. I am assuming there is still need for
that locking. The filter/classification scheme still works as is and
select classes which map to rings. tc still works as is etc.

cheers,
jamal
