From: stefano babic <stefano.babic@babic.homelinux.org>
Subject: Re: [RFC PATCH v3  4/8] CAIF Protocol Stack
Date: Tue, 15 Dec 2009 17:47:11 +0100
Message-ID: <4B27BD8F.5040606@babic.homelinux.org>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, randy.dunlap@oracle.com,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout18.attiva.biz ([85.37.16.20]:19725 "EHLO
	smtpout18.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932384AbZLOQrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 11:47:17 -0500
In-Reply-To: <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> +struct cfcnfg *cfcnfg_create()
> +{
> +	struct cfcnfg *this;
> +	struct cfctrl_rsp resp;
> +	/* Initiate response functions */
> +	resp.enum_rsp = cfctrl_enum_resp;
> +	resp.linkerror_ind = cfctrl_resp_func;
> +	resp.linkdestroy_rsp = cncfg_linkdestroy_rsp;
> +	resp.sleep_rsp = cfctrl_resp_func;
> +	resp.wake_rsp = cfctrl_resp_func;
> +	resp.restart_rsp = cfctrl_resp_func;
> +	resp.radioset_rsp = cfctrl_resp_func;
> +	resp.linksetup_rsp = cncfg_linkup_rsp;
> +	resp.reject_rsp = cncfg_reject_rsp;
> +	/* Initiate this layer */
> +	this = cfglu_alloc(sizeof(struct cfcnfg));
> +	memset(this, 0, sizeof(struct cfcnfg));
> +	this->mux = cfmuxl_create();
> +	this->ctrl = cfctrl_create();
> +	this->last_phyid = 1;
> +	cfctrl_set_respfuncs(this->ctrl, &resp);

Is this correct ? resp is on the stack of the function and
cfctrl_set_respfuncs sets only the pointer. After returning from this
function, the memory used by resp could be reused again. Am I right ?

> +static void cfctrl_resp_func(void)
> +{
> +	CFLOG_ENTER(("cfcnfg: cfctrl_resp_func\n"));
> +	CFLOG_EXIT(("cfcnfg: cfctrl_resp_func\n"));
> +}

Not really useful..

Stefano
-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
