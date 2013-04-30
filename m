From: Vipul Pandya <vipul@chelsio.com>
Subject: Re: [PATCH net 3/3] cxgb4vf: Support CPL_SGE_EGR_UPDATEs encapsulated
 in a CPL_FW4_MSG
Date: Tue, 30 Apr 2013 12:16:13 +0530
Message-ID: <517F68B5.6010206@chelsio.com>
References: <1367244281-23043-1-git-send-email-vipul@chelsio.com> <1367244281-23043-4-git-send-email-vipul@chelsio.com> <517EC22F.9020102@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Abhishek Agrawal <abhishek@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	SWise OGC <swise@opengridcomputing.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18875 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037Ab3D3GqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 02:46:23 -0400
In-Reply-To: <517EC22F.9020102@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 30-04-2013 00:25, Sergei Shtylyov wrote:
> Hello.
> 
> On 04/29/2013 06:04 PM, Vipul Pandya wrote:
> 
>> Newer firmware can post CPL_SGE_EGR_UPDATE message encapsulated in a
>> CPL_FW4_MSG as follows
>>
>> flit0 rss_header (if DropRSS == 0 in IQ context)
>> flit1 CPL_FW4_MSG cpl
>> flit2 rss_header w/opcode CPL_SGE_EGR_UPDATE
>> flit3 CPL_SGE_EGR_UPDATE cpl
>>
>> So FW4_MSG CPLs with a newly created type of FW_TYPE_RSSCPL have the
>> CPL_SGE_EGR_UPDATE CPL message in flit 2 of the FW4_MSG. Firmware can still
>> post regular CPL_SGE_EGR_UPDATE messages, so the drivers need to handle
>> both.
>>
>> This patch also writes a new parameter to firmware requesting encapsulated
>> EGR_UPDATE. This allows firmware with this support to not break older drivers.
>>
>> Signed-off-by: Vipul Pandya <vipul@chelsio.com>
> 
> [...]
> 
>> diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
>> index 73aef76..40c22e7 100644
>> --- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
>> +++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
>> @@ -409,6 +409,20 @@ static int fwevtq_handler(struct sge_rspq *rspq, const __be64 *rsp,
>>   		break;
>>   	}
>>   
>> +	case CPL_FW4_MSG: {
>> +		/* FW can send EGR_UPDATEs encapsulated in a CPL_FW4_MSG.
>> +		 */
>> +		const struct cpl_sge_egr_update *p = (void *)(rsp + 3);
> 
>      Empty line wouldn't hurt here, after the declaration.
> 
>> +		opcode = G_CPL_OPCODE(ntohl(p->opcode_qid));
>> +		if (opcode != CPL_SGE_EGR_UPDATE) {
>> +			dev_err(adapter->pdev_dev, "unexpected FW4/CPL %#x on FW event queue\n"
>> +				, opcode);
>> +			break;
>> +		}
>> +		cpl = (void *)p;
>> +		/*FALLTHROUGH*/
> 
>     Rather pointless comment at end of *switch*. Adn you forgot to add 
> spaced before */ and after /*.
> 
>> +	}
>> +
>>   	case CPL_SGE_EGR_UPDATE: {
>>   		/*
>>   		 * We've received an Egress Queue Status Update message.  We
> [...]
> 
> WBR, Sergei
> 

Hello Sergei,

Thank you for your comments. I will take care and address them in future.

Thanks,
Vipul
