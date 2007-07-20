From: Patrick McHardy <kaber@trash.net>
Subject: [ofa-general] Re: [PATCH 05/10] sch_generic.c changes.
Date: Fri, 20 Jul 2007 12:11:01 +0200
Message-ID: <46A08A35.5090104@trash.net>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
	<20070720063249.26341.125.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	mcarlson@broadcom.com, netdev@vger.kernel.org, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, hadi@cyberus.ca, davem@davemloft.net, sri@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720063249.26341.125.sendpatchset@localhost.localdomain>
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

Krishna Kumar wrote:
> diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
> --- org/net/sched/sch_generic.c	2007-07-20 07:49:28.000000000 +0530
> +++ new/net/sched/sch_generic.c	2007-07-20 08:30:22.000000000 +0530
> @@ -9,6 +9,11 @@
>   * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
>   *              Jamal Hadi Salim, <hadi@cyberus.ca> 990601
>   *              - Ingress support
> + *
> + * New functionality:
> + *		Krishna Kumar, <krkumar2@in.ibm.com>, July 2007
> + *		- Support for sending multiple skbs to devices that support
> + *		  new api - dev->hard_start_xmit_batch()


No new changelogs in source code please, git keeps track of that.

> -static inline int qdisc_restart(struct net_device *dev)
> +static inline int qdisc_restart(struct net_device *dev,
> +				struct sk_buff_head *blist)
>  {
>  	struct Qdisc *q = dev->qdisc;
>  	struct sk_buff *skb;
> -	unsigned lockless;
> +	unsigned getlock;		/* whether we need to get lock or not */


Unrelated rename, please get rid of this to reduce the noise.
