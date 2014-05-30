From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next 5/6] be2net: move async cmd processing to a
 separate routine
Date: Fri, 30 May 2014 09:18:34 +0000
Message-ID: <85723bf9-d7da-4d31-9abb-d50b58e1a172@CMEXHTCAS2.ad.emulex.com>
References: <1401258665-6238-1-git-send-email-sathya.perla@emulex.com>
 <1401258665-6238-6-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Sathya Perla <Sathya.Perla@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:42569 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504AbaE3JSk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 05:18:40 -0400
In-Reply-To: <1401258665-6238-6-git-send-email-sathya.perla@emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Sathya Perla
...
> 
>
>  static int be_mcc_compl_process(struct be_adapter *adapter,
>  				struct be_mcc_compl *compl)
>  {
>  	enum mcc_base_status base_status;
>  	enum mcc_addl_status addl_status;
>  	struct be_cmd_resp_hdr *resp_hdr;
> -	u8 opcode = 0, subsystem = 0;
> +	u8 opcode, subsystem;
> 
>  	/* Just swap the status to host endian; mcc tag is opaquely copied
>  	 * from mcc_wrb */
> @@ -148,45 +196,13 @@ static int be_mcc_compl_process(struct be_adapter
> *adapter,
>  	addl_status = addl_status(compl->status);
> 
>  	resp_hdr = be_decode_resp_hdr(compl->tag0, compl->tag1);
> +	opcode = resp_hdr->opcode;
> +	subsystem = resp_hdr->subsystem;
> 
> -	if (resp_hdr) {
> -		opcode = resp_hdr->opcode;
> -		subsystem = resp_hdr->subsystem;
> -	}
> -

I missed a NULL check here. I'll fix this up and re-send the patch set.
Thanks!

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
