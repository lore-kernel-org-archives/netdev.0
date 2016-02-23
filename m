From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Tue, 23 Feb 2016 14:32:35 +0100
Message-ID: <56CC5F73.9080201@iogearbox.net>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com> <1456231760-2513-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	dj@verizon.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46565 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbcBWNci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 08:32:38 -0500
In-Reply-To: <1456231760-2513-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2016 01:49 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> This action allows for a sending side to encapsulate arbitrary metadata
> which is decapsulated by the receiving end.
> The sender runs in encoding mode and the receiver in decode mode.
> Both sender and receiver must specify the same ethertype.
> At some point we hope to have a registered ethertype and we'll
> then provide a default so the user doesnt have to specify it.
> For now we enforce the user specify it.
>
> Lets show example usage where we encode icmp from a sender towards
> a receiver with an skbmark of 17; both sender and receiver use
> ethertype of 0xdead to interop.

On a conceptual level, as this is an L2 encap with TLVs, why not having
a normal device driver for this like we have in other cases that would
encode/decode the meta data itself?

[...]
> +/*XXX: We need to encode the total number of bytes consumed */
> +enum {
> +	TCA_IFE_UNSPEC,
> +	TCA_IFE_PARMS,
> +	TCA_IFE_TM,
> +	TCA_IFE_DMAC,
> +	TCA_IFE_SMAC,
> +	TCA_IFE_TYPE,
> +	TCA_IFE_METALST,
> +	__TCA_IFE_MAX
> +};
> +#define TCA_IFE_MAX (__TCA_IFE_MAX - 1)
> +
> +#define IFE_META_SKBMARK 1
> +#define IFE_META_HASHID 2
> +#define	IFE_META_PRIO 3
> +#define	IFE_META_QMAP 4
> +/*Can be overriden at runtime by module option*/
> +#define	__IFE_META_MAX 5
> +#define IFE_META_MAX (__IFE_META_MAX - 1)
> +
> +#endif
[...]
> +module_init(ife_init_module);
> +module_exit(ife_cleanup_module);
> +
> +module_param(max_metacnt, int, 0);
> +MODULE_AUTHOR("Jamal Hadi Salim(2015)");
> +MODULE_DESCRIPTION("Inter-FE LFB action");
> +MODULE_LICENSE("GPL");
> +MODULE_PARM_DESC(max_metacnt, "Upper bound of metadata id");

Why does IFE_META_MAX need to be configurable as a module parameter?

Shouldn't the core kernel be in charge of the IFE_META_*?

Thanks,
Daniel
