From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 3/9 Rev3] [sched] Modify qdisc_run to
	support batching
Date: Wed, 08 Aug 2007 11:26:05 -0400
Message-ID: <1186586765.5155.39.camel@localhost>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
	<20070808093145.15396.91711.sendpatchset@localhost.localdomain>
	<46B9CD9D.4020506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, netdev@vger.kernel.org, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, shemminger@linux-foundation.org,
	davem@davemloft.net, sri@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46B9CD9D.4020506@trash.net>
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

On Wed, 2007-08-08 at 16:05 +0200, Patrick McHardy wrote:

> This is not completely avoidable of
> course, but you can and should limit the damage by only pulling
> out as much packets as the driver can take and have the driver
> stop the queue afterwards.

This why the dev->xmit_win exists in my patches. The driver says how
much space it has using this variable - and only those packets get
pulled off; so there is no conflict with any scheduling algorithm be it
work/non-work conserving. 
The ideal case is never to carry over anything in dev->blist. However,
there is a challenge with GSO/TSO: if say the descriptors in the driver
are less than the list of skbs, you are faced with the dilema of sending
a fraction of the gso list first.
My current approach is to transmit as much as the driver would allow.
On the next opportunity to transmit, you do immediately send anything
remaining first before you ask the qdisc for more packets. An
alternative approach i had entertained was not to send anything from the
skb list when hitting such a case, but it hasnt seem needed so far
(havent seen any leftovers from my experiments).

cheers,
jamal
