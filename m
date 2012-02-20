From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 1/2] netdev: driver: ethernet: add cpsw address
 lookup engine support
Date: Mon, 20 Feb 2012 14:37:32 -0800
Message-ID: <1329777452.8318.5.camel@joe2Laptop>
References: <1329763023-29580-1-git-send-email-mugunthanvnm@ti.com>
	 <1329763023-29580-2-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33102 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754442Ab2BTWhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 17:37:34 -0500
In-Reply-To: <1329763023-29580-2-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-21 at 00:07 +0530, Mugunthan V N wrote:
> TI CPSW ethernet switch has a built-in address lookup engine.  This patch adds
> the code necessary for programming this module.

just some style notes.

> diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
[]
> +struct ale_control_info {
> +	const char	*name;
> +	int		offset, port_offset;
> +	int		shift, port_shift;
> +	int		bits;
> +};
> +
> +#define CTRL_GLOBAL(name, bit)		{#name, ALE_CONTROL, 0, bit, 0, 1}
> +#define CTRL_UNK(name, shift, bits)	{#name, ALE_UNKNOWNVLAN, 0, shift, \
> +						0, bits}
> +#define CTRL_PORTCTL(name, start, bits)	{#name, ALE_PORTCTL, 4, start, 0, bits}

named initializers might be more readable,
embedding the index might be too.
[]

> +struct cpsw_ale *cpsw_ale_create(struct cpsw_ale_params *params)
> +{
> +	struct cpsw_ale *ale;
> +	int ret;
> +
> +	ret = -ENOMEM;
> +	ale = kzalloc(sizeof(*ale), GFP_KERNEL);
> +	if (WARN_ON(!ale))
> +		return NULL;

The WARN_ON is unnecessary.  alloc failures get a dump_stack.

> diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
[]
> +struct cpsw_ale {
> +	struct cpsw_ale_params	params;
> +	struct timer_list	timer;
> +	unsigned long		ageout;
> +	struct device_attribute ale_control_attr;
> +#define control_attr_to_ale(attr)	\
> +	container_of(attr, struct cpsw_ale, ale_control_attr);
> +	struct device_attribute ale_table_attr;
> +#define table_attr_to_ale(attr)		\
> +	container_of(attr, struct cpsw_ale, ale_table_attr);
> +};

Embedding the #defines in a struct makes it difficult to read.
Perhaps this is simpler:

struct cpsw_ale {
	struct cpsw_ale_params	params;
	struct timer_list	timer;
	unsigned long		ageout;
	struct device_attribute ale_control_attr;
	struct device_attribute ale_table_attr;
};

#define control_attr_to_ale(attr)	\
	container_of(attr, struct cpsw_ale, ale_control_attr);
#define table_attr_to_ale(attr)		\
	container_of(attr, struct cpsw_ale, ale_table_attr);
