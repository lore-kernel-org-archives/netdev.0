From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [RFC PATCH v3  4/8] CAIF Protocol Stack
Date: Wed, 16 Dec 2009 17:16:43 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E079031549D2@eseldmw101.eemea.ericsson.se>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com> <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com> <4B27BD8F.5040606@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <randy.dunlap@oracle.com>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>,
	"Christian Bejram" <christian.bejram@stericsson.com>,
	"Daniel Martensson" <daniel.martensson@stericsson.com>
To: "stefano babic" <stefano.babic@babic.homelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:58943 "EHLO
	mailgw4.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbZLPQV3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 11:21:29 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B27BD8F.5040606@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stefano babic wrote:
> sjur.brandeland@stericsson.com wrote:
>> +struct cfcnfg *cfcnfg_create()
>> +{
>> +	struct cfcnfg *this;
>> +	struct cfctrl_rsp resp;
>> +	/* Initiate response functions */
>> +	resp.enum_rsp = cfctrl_enum_resp;
>> +	resp.linkerror_ind = cfctrl_resp_func;
>> +	resp.linkdestroy_rsp = cncfg_linkdestroy_rsp;
...
>> +	cfctrl_set_respfuncs(this->ctrl, &resp);
> 
> Is this correct ? resp is on the stack of the function and
> cfctrl_set_respfuncs sets only the pointer. After returning from this
> function, the memory used by resp could be reused again. Am I right ?
> 
Yes it is correct. But it sure looks odd, so I'll change this. 
But it's actually working because the content is copied by the statement 
this->res = *respfuncs; in cfctrl.c.

I'll change this code to something like this:
[snip]
	resp = cfctrl_get_respfuncs(this->ctrl);
	resp->enum_rsp = cfctrl_enum_resp;
	resp->linkerror_ind = cfctrl_resp_func;
	resp->linkdestroy_rsp = cncfg_linkdestroy_rsp;
	...
BR/Sjur

