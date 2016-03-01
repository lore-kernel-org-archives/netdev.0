From: Brian Russell <brian.russell@brocade.com>
Subject: Re: [PATCH net-next v2 2/2] vxlan: support GPE/NSH
Date: Tue, 1 Mar 2016 11:10:40 +0000
Message-ID: <56D578B0.9020605@brocade.com>
References: <1455220626-28244-1-git-send-email-brussell@brocade.com>
 <1455220626-28244-3-git-send-email-brussell@brocade.com>
 <20160215174917.025b066c@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:51315 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751965AbcCALKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:10:54 -0500
In-Reply-To: <20160215174917.025b066c@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 15/02/16 16:49, Jiri Benc wrote:
> On Thu, 11 Feb 2016 19:57:06 +0000, Brian Russell wrote:
>> +skip_l2:
>>  	skb_reset_network_header(skb);
>> +
>>  	/* In flow-based mode, GBP is carried in dst_metadata */
>> -	if (!(vs->flags & VXLAN_F_COLLECT_METADATA))
>> +	if (!(vs->flags & VXLAN_F_COLLECT_METADATA) &&
>> +	    !(vs->flags & VXLAN_F_GPE))
>>  		skb->mark = md->gbp;
> 
> This is completely wrong. You cannot return a packet with a garbage in
> place of the Ethernet header from ARPHRD_ETHER interface. For proper
> VXLAN-GPE support, the vxlan interface needs to be in L3 mode, e.g.
> ARPHRD_NONE.
> 

Yes, I see that, thanks for the clarification. (I was "getting away with" the broken code in my test as I was diverting packets bound for another interface onto the vxlan via a netfilter target.)

> To support L3 mode, the vxlan driver needs *tons* of cleanups (or tons
> of duplicate code). This is exactly what I've done and what I'm in
> process of merging. The number of patches is too big to be submitted as
> a single patchset, hence I'm submitting in parts. The first one has
> been already merged (net-next commit 19f76f63507f). For the full code,
> look at: https://urldefense.proofpoint.com/v2/url?u=https-3A__github.com_jbenc_linux-2Dvxlan_commits_master&d=CwICAg&c=IL_XqQWOjubgfqINi2jTzg&r=Doie302MT-sezztwQymkPQ3_4X5Q3a0mKbiZzzoNm-0&m=dDreCW0fBOYAR9o10-A-Ifd5jVGfykbZGpkzbN11nMc&s=qdPcZavap7kJQOuN2Udz-h-CDNkP4GiV_CYrQwXD_Kg&e= 
> 
> Comments are welcome.
> 

This looks great so I'll drop my vxlan-gpe patch. I'd like to add the NSH capability on top of your patchset which I see is currently under review. Or did you have plans to roll out NSH soon also?

Thanks,

Brian

>  Jiri
> 
