From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 3/5] Support to encoding decoding skb prio on
 IFE action
Date: Mon, 22 Feb 2016 18:01:11 +0100
Message-ID: <56CB3ED7.90202@iogearbox.net>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com> <1456147304-13355-4-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39055 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbcBVRBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 12:01:19 -0500
In-Reply-To: <1456147304-13355-4-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2016 02:21 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
[...]
> +static int skbprio_check(struct sk_buff *skb, struct tcf_meta_info *e)
> +{
> +	return check_meta_u32(skb->priority, e);
> +}
> +
> +static int skbprio_encode(struct sk_buff *skb, void *skbdata,
> +			  struct tcf_meta_info *e)
> +{
> +	u32 ifeprio = skb->priority; /* avoid having to cast skb->priority*/
> +
> +	pr_emerg("encode skbprio %d\n", ifeprio);

Ditto ... and this for every packet on encap and decap ...

> +	return encode_meta_u32(ifeprio, skbdata, e);
> +}
> +
> +static int skbprio_decode(struct sk_buff *skb, void *data, u16 len)
> +{
> +	u32 ifeprio = *(u32 *) data;
> +
> +	skb->priority = ntohl(ifeprio);
> +	pr_emerg("decode skbprio %d\n", skb->priority);
> +	return 0;
> +}
> +
> +static struct tcf_meta_ops ife_prio_ops = {
> +	.metaid = IFE_META_PRIO,
> +	.metatype = NLA_U32,
> +	.name = "skbprio",
> +	.synopsis = "skb prio metadata",
> +	.check_presence = skbprio_check,
> +	.encode = skbprio_encode,
> +	.decode = skbprio_decode,
> +	.get = get_meta_u32,
> +	.alloc = alloc_meta_u32,
> +	.owner = THIS_MODULE,
> +};
> +
> +static int __init ifeprio_init_module(void)
> +{
> +	pr_info("Loaded IFE skb prio\n");
> +	return register_ife_op(&ife_prio_ops);
> +}
> +
> +static void __exit ifeprio_cleanup_module(void)
> +{
> +	unregister_ife_op(&ife_prio_ops);
> +	pr_info("Unloaded IFE skb prio\n");
> +}
> +
> +module_init(ifeprio_init_module);
> +module_exit(ifeprio_cleanup_module);
> +
> +MODULE_AUTHOR("Jamal Hadi Salim(2015)");
> +MODULE_DESCRIPTION("Inter-FE skb prio metadata action");
> +MODULE_LICENSE("GPL");
> +MODULE_ALIAS_IFE_META(IFE_META_PRIO);
>
