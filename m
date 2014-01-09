From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] include/uapi/linux/xfrm.h: Pack struct xfrm_userpolicy_info
Date: Fri, 10 Jan 2014 02:07:19 +0300
Message-ID: <52CF2BA7.9080408@cogentembedded.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com> <1389077339-12814-2-git-send-email-fan.du@windriver.com> <52CC851B.2060401@cogentembedded.com> <52CE6052.5030905@windriver.com> <52CF29B1.1000905@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	stephen@networkplumber.org, dev@lists.strongswan.org,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:40140 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbaAIWHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 17:07:20 -0500
Received: by mail-lb0-f177.google.com with SMTP id z5so446231lbh.36
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 14:07:16 -0800 (PST)
In-Reply-To: <52CF29B1.1000905@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2014 01:58 AM, Sergei Shtylyov wrote:

>>>> Otherwise 64bits kernel has sizeof(struct xfrm_userpolicy_info) 168 bytes,
>>>> while 32bits compiled iproute2 see the same structure as 164 bytes, which
>>>> leading deficit xfrm policy, in turn broken IPsec connectivity.

>>>> Fix this by packing the structure.

>>>     This will force byte-by-byte access to all members on some arches like
>>> ARM...

>>>> Signed-off-by: Fan Du <fan.du@windriver.com>
>>>> ---
>>>>   include/uapi/linux/xfrm.h |    2 +-
>>>>   1 file changed, 1 insertion(+), 1 deletion(-)

>>>> diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
>>>> index a8cd6a4..470bfae 100644
>>>> --- a/include/uapi/linux/xfrm.h
>>>> +++ b/include/uapi/linux/xfrm.h
>>>> @@ -405,7 +405,7 @@ struct xfrm_userpolicy_info {
>>>>       /* Automatically expand selector to include matching ICMP payloads. */
>>>>   #define XFRM_POLICY_ICMP    2
>>>>       __u8                share;
>>>> -};
>>>> +} __attribute__((packed));

>>>     Please use the __packed macro instead. I guess you haven't run
>>> checkpatch.pl?

>> Lucky me, I run checkpatch every time before sending patch out.

>     Ah, this time it didn't have the *struct* start in the context, so that's
> why there was no complaint (probably). Usually, it suggests using __packed...

    Ah, no. Looking at the script, it just doesn't WARN about this in the 
files under include/uapi/. Probably the macro is undefined in this context.

WBR, Sergei
