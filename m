From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [PATCH] [CAIF-RFC 4/8-v2] CAIF Protocol Stack
Date: Mon, 12 Oct 2009 14:20:01 +0200
Message-ID: <4AD31EF1.2010102@babic.homelinux.org>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-3-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-4-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-5-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout13.attiva.biz ([85.37.16.15]:44699 "EHLO
	smtpout13.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552AbZJLMUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 08:20:41 -0400
In-Reply-To: <1255095571-6501-5-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Hi Sjur,

> 
> diff --git a/net/caif/generic/cfcnfg.c b/net/caif/generic/cfcnfg.c
> new file mode 100644
> index 0000000..3aad201

> + * NOTE: What happends destroy failure:

s/happends/happens/, there are other occurencies.

> +
> +bool cfcnfg_del_adapt_layer(struct _cfcnfg_t *cnfg, layer_t *adap_layer)
> +{
> +	uint8 channel_id = 0;
> +	struct cfcnfg_phyinfo *phyinfo = NULL;
> +	uint8 phyid = 0;
> +	CFLOG_TRACE(("cfcnfg: enter del_adaptation_layer\n"));
> +
> +	cfglu_assert(adap_layer != NULL);
> +	channel_id = adap_layer->id;
> +	cfglu_assert(channel_id != 0);

My two cents about using assert in the code, but I prefer to get some
info from system when something goes wrong as to call in some way panic
(the assert calls BUG_ON) and blocks forever.
This line is not different as checking the adapt_layer->dn pointer some
lines after and I think an error is better recognized in that case. So
IMHO should be better something like:

	if (channel_id == 0) {
		CFLOG_ERROR(("cfcnfg:adap_layer->dn is NULL\n"));
		return CFGLU_EINVAL;
	}


> diff --git a/net/caif/generic/cfpkt_plain.c b/net/caif/generic/cfpkt_plain.c
> +#define CHECK_MEM 1

Probably you plan to use always the magic number in your buffer
management. Then should be better to remove all the #if CHECK_MEM stuff.


> +#if CHECK_MEM
> +
> +#endif

This three lines seem not needed.... ;)

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
