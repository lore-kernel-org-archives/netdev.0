From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Mon, 27 Dec 2004 13:16:58 +0100
Message-ID: <20041227121658.GI7884@postel.suug.ch>
References: <200412270715.iBR7Fffe026855@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <200412270715.iBR7Fffe026855@hera.kernel.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> ChangeSet 1.2055.37.1, 2004/11/17 16:08:01-08:00, util@deuroconsult.ro
> 
> 	[PKT_SCHED]: Allow using nfmark as key in U32 classifier.
> 	
> 	Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>
> 	Signed-off-by: David S. Miller <davem@davemloft.net>

I must have missed this one. This should have been implemented in the
metadata action module to make it available to all classifiers. We
should really stop to add more stuff to specific classifiers which have
to be removed once we have metamatch. I've made a proposal on paper
just need some more time to cook up a patch.

> +#ifdef CONFIG_CLS_U32_MARK                                                                                                                                             
> +	if (tb[TCA_U32_MARK-1]) {
> +		if (RTA_PAYLOAD(tb[TCA_U32_MARK-1]) < sizeof(struct tc_u32_mark))
> +			return -EINVAL;
> +		mark = RTA_DATA(tb[TCA_U32_MARK-1]);
> +		memcpy(&n->mark, mark, sizeof(struct tc_u32_mark));
> +		n->mark.success = 0;
> +	}                                                                                                                                                                
> +#endif                                                                                                                                                                 

This should have gone into u32_set_params
