From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 19:45:17 -0700 (PDT)
Message-ID: <20071008.194517.32744598.davem@davemloft.net>
References: <20071009020115.GA14635@gondor.apana.org.au>
	<20071009020318.GA14708@gondor.apana.org.au>
	<20071009020442.GA14746@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, jeff@garzik.org, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, gaagaan@gmail.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, shemminger@linux-foundation.org,
	kaber@trash.net, sri@us.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009020442.GA14746@gondor.apana.org.au>
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

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 9 Oct 2007 10:04:42 +0800

> On Tue, Oct 09, 2007 at 10:03:18AM +0800, Herbert Xu wrote:
> > On Tue, Oct 09, 2007 at 10:01:15AM +0800, Herbert Xu wrote:
> > > On Mon, Oct 08, 2007 at 06:41:26PM -0700, David Miller wrote:
> > > >
> > > > I also want to point out another issue.  Any argument wrt. reordering
> > > > is specious at best because right now reordering from qdisc to device
> > > > happens anyways.
> > > 
> > > This is not true.
> > > 
> > > If your device has a qdisc at all, then you will end up in the
> > > function qdisc_restart, where we release the queue lock only
> > > after acquiring the TX lock.
> > > 
> > > So right now this path does not create any reordering.
> > 
> > Argh! Someone's just broken this.  I think we should restore
> > the original behaviour.
> 
> Please revert
> 
> commit 41843197b17bdfb1f97af0a87c06d24c1620ba90
> Author: Jamal Hadi Salim <hadi@cyberus.ca>
> Date:   Tue Sep 25 19:27:13 2007 -0700
> 
>     [NET_SCHED]: explict hold dev tx lock
> 
> As this change introduces potential reordering and I don't think
> we've discussed this aspect sufficiently.

Agreed, and done.
