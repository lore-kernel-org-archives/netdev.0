From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: suppress repeated error messages about Max
 BW
Date: Mon, 15 Aug 2011 15:33:05 +0300
Message-ID: <1313411585.31417.35.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20110812143324.5740.45824.stgit@dhcp-29-224.brq.redhat.com>
 <1313405680.31417.6.camel@lb-tlvb-eilong.il.broadcom.com>
 <4E490A1E.3060209@redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2276 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752921Ab1HOMdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2011 08:33:19 -0400
In-Reply-To: <4E490A1E.3060209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-15 at 04:59 -0700, Michal Schmidt wrote:
> On 08/15/2011 12:54 PM, Eilon Greenstein wrote:
> > On Fri, 2011-08-12 at 07:33 -0700, Michal Schmidt wrote:
> >> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> >> index c423504..648e165 100644
> >> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> >> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> >> @@ -1220,6 +1220,7 @@ struct bnx2x {
> >>   	struct cmng_struct_per_port cmng;
> >>   	u32			vn_weight_sum;
> >>   	u32			mf_config[E1HVN_MAX];
> >> +	bool			prev_max_cfg_invalid[E1HVN_MAX];
> > The warning is always for the current VN, so if you insist on showing a
> > warning only once on a board with invalid configuration, you can use a
> > single boolean.
> 
> bnx2x_cmng_fns_init() iterates over VNs:
> 
>       for (vn = VN_0; vn < E1HVN_MAX; vn++)
>               bnx2x_init_vn_minmax(bp, vn);
> 
> and bnx2x_init_vn_minmax() calls bnx2x_extract_max_cfg() on the given 
> VN, so it seems that the warning can be produced for a non-current VN.

You are right, only one function (the PMF) will call this code for all
functions. But I suspect that if you have zero values, you will have
them for all VNs - is that the case? If so, you can still warn only
once. Adding 4 boolean variables to the bnx2x structure just to overcome
a bad configuration seems excessive to me.




