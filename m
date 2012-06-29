From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next] em_canid: Ematch rule to match CAN frames according
 to their identifiers
Date: Fri, 29 Jun 2012 17:44:02 +0200
Message-ID: <4FEDCD42.8010203@hartkopp.net>
References: <1340903231-9561-1-git-send-email-lisovy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Rostislav Lisovy <lisovy@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1340903231-9561-1-git-send-email-lisovy@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Rostislav,

looks really good now.

1. Your Signed-off-by: is missing.

2. One remark to a removed length check:

(..)

> +static int em_canid_change(struct tcf_proto *tp, void *data, int len,
> +			  struct tcf_ematch *m)
> +{
> +	struct can_filter *conf = data; /* Array with rules,
> +					 * fixed size EM_CAN_RULES_SIZE
> +					 */
> +	struct canid_match *cm;
> +	struct canid_match *cm_old = (struct canid_match *) m->data;
> +	int i;
> +	int rulescnt;
> +


What about a zero length check here?

	if (!len)
		return -EINVAL;

???

> +	if (len % sizeof(struct can_filter))
> +		return -EINVAL;
> +
> +	if (len > sizeof(struct can_filter) * EM_CAN_RULES_MAX)
> +		return -EINVAL;
> +
> +	rulescnt = len / sizeof(struct can_filter);
> +
> +	cm = kzalloc(sizeof(struct canid_match) + sizeof(struct can_filter) *
> +		rulescnt, GFP_KERNEL);
> +	if (!cm)
> +		return -ENOMEM;


The length could alternatively be checked here too

http://lxr.linux.no/#linux+v3.4.4/net/sched/ematch.c#L235

if em->ops->datalen is set.

But here's no

	.datalen = sizeof(struct can_filter),

defined, right?

> +static struct tcf_ematch_ops em_canid_ops = {
> +	.kind	  = TCF_EM_CANID,
> +	.change	  = em_canid_change,
> +	.match	  = em_canid_match,
> +	.destroy  = em_canid_destroy,
> +	.dump	  = em_canid_dump,
> +	.owner	  = THIS_MODULE,
> +	.link	  = LIST_HEAD_INIT(em_canid_ops.link)
> +};


Regards,
Oliver
