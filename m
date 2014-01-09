From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] include/uapi/linux/xfrm.h: Pack struct xfrm_userpolicy_info
Date: Fri, 10 Jan 2014 01:58:57 +0300
Message-ID: <52CF29B1.1000905@cogentembedded.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com> <1389077339-12814-2-git-send-email-fan.du@windriver.com> <52CC851B.2060401@cogentembedded.com> <52CE6052.5030905@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	stephen@networkplumber.org, dev@lists.strongswan.org,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:56778 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbaAIV6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 16:58:55 -0500
Received: by mail-la0-f47.google.com with SMTP id eh20so412653lab.6
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 13:58:53 -0800 (PST)
In-Reply-To: <52CE6052.5030905@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2014 11:39 AM, Fan Du wrote:

>>> Otherwise 64bits kernel has sizeof(struct xfrm_userpolicy_info) 168 bytes,
>>> while 32bits compiled iproute2 see the same structure as 164 bytes, which
>>> leading deficit xfrm policy, in turn broken IPsec connectivity.

>>> Fix this by packing the structure.

>>     This will force byte-by-byte access to all members on some arches like
>> ARM...

>>> Signed-off-by: Fan Du <fan.du@windriver.com>
>>> ---
>>>   include/uapi/linux/xfrm.h |    2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)

>>> diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
>>> index a8cd6a4..470bfae 100644
>>> --- a/include/uapi/linux/xfrm.h
>>> +++ b/include/uapi/linux/xfrm.h
>>> @@ -405,7 +405,7 @@ struct xfrm_userpolicy_info {
>>>       /* Automatically expand selector to include matching ICMP payloads. */
>>>   #define XFRM_POLICY_ICMP    2
>>>       __u8                share;
>>> -};
>>> +} __attribute__((packed));

>>     Please use the __packed macro instead. I guess you haven't run
>> checkpatch.pl?

> Lucky me, I run checkpatch every time before sending patch out.

    Ah, this time it didn't have the *struct* start in the context, so that's 
why there was no complaint (probably). Usually, it suggests using __packed...

WBR, Sergei
