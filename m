From: Brian Russell <brian.russell@brocade.com>
Subject: Re: [PATCH net-next v2 1/2] nsh: encapsulation module
Date: Tue, 1 Mar 2016 11:11:33 +0000
Message-ID: <56D578E5.2030704@brocade.com>
References: <1455220626-28244-1-git-send-email-brussell@brocade.com>
 <1455220626-28244-2-git-send-email-brussell@brocade.com>
 <20160217033132.GA47212@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:29213 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751965AbcCALLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:11:44 -0500
In-Reply-To: <20160217033132.GA47212@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/02/16 03:31, Alexei Starovoitov wrote:
> On Thu, Feb 11, 2016 at 07:57:05PM +0000, Brian Russell wrote:
>> Support encap/decap of Network Service Header (NSH) as defined in
>> https://urldefense.proofpoint.com/v2/url?u=https-3A__tools.ietf.org_html_draft-2Dietf-2Dsfc-2Dnsh-2D01&d=CwIBAg&c=IL_XqQWOjubgfqINi2jTzg&r=Doie302MT-sezztwQymkPQ3_4X5Q3a0mKbiZzzoNm-0&m=TRPN3Zh-t31lBDA9ENrL1q3xeXBbMVLbXQhuldfgGN4&s=2lOXPH9TaoFa0x2lbk74kXi0vaLni54K6Hwjlb_Zs5k&e= 
>>
>> Includes support for Type 1 and Type 2 metadata and a simple registration
>> for listeners to see decapsulated packets based on the Type/Class.
>>
>> Signed-off-by: Brian Russell <brussell@brocade.com>
> ...
>> +int nsh_register_listener(struct nsh_listener *listener)
>> +{
>> +	if (listener->max_ctx_hdrs > limit_ctx_hdrs)
>> +		return -ENOMEM;
>> +
>> +	mutex_lock(&nsh_listener_mutex);
>> +	list_add(&listener->list, &nsh_listeners);
>> +	mutex_unlock(&nsh_listener_mutex);
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL(nsh_register_listener);
>> +EXPORT_SYMBOL(nsh_unregister_listener);
> 
> looks like this patch doesn't actually implement the protocol,
> but rather provides a placeholder for out of tree modules?
> 

It implements the protocol in terms of the NSH base and service path headers and it decaps the metadata if present. However, the actual interpretation of that metadata is left to registered listeners which might be out of tree modules. The NSH standard defines the mechanism to carry metadata but does not limit how it is used.

Thanks,

Brian
