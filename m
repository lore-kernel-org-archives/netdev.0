From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] SCTP: Fix miss of report unrecognized HMAC Algorithm parameter
Date: Mon, 28 Jan 2008 08:50:07 +0900
Message-ID: <479D18AF.7000802@cn.fujitsu.com>
References: <47968AA3.2060704@cn.fujitsu.com> <20080124130551.GA24331@hmsreliant.think-freely.org> <479A1422.3090304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:42785 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbYA0Xu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2008 18:50:56 -0500
In-Reply-To: <479A1422.3090304@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix miss of check for report unrecognized HMAC Algorithm 
parameter.
When AUTH is disabled, goto fall through path to report unrecognized 
parameter, else, just break.
> Wei
>
> Neil Horman wrote:
>> On Wed, Jan 23, 2008 at 09:30:27AM +0900, Wei Yongjun wrote:
>>> This patch fix miss of check for report unrecognized HMAC Algorithm 
>>> parameter.
>>> When AUTH is disabled, goto fall through path to report unrecognized 
>>> parameter, else, just break.
>>>
>>>
>>
>> Acked-by: Neil Horman <nhorman@tuxdriver.com>
>>
>> Neil
>>
>
> Can you please send this to netdev and CC Dave Miller..
>
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>
> -vlad
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>


--- a/net/sctp/sm_make_chunk.c	2008-01-21 00:03:25.000000000 -0500
+++ b/net/sctp/sm_make_chunk.c	2008-01-21 02:33:36.000000000 -0500
@@ -2014,7 +2014,7 @@ static sctp_ierror_t sctp_verify_param(c
 		break;
 
 	case SCTP_PARAM_HMAC_ALGO:
-		if (!sctp_auth_enable)
+		if (sctp_auth_enable)
 			break;
 		/* Fall Through */
 fallthrough:


