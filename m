From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] SCTP: Fix sctp_auth_asoc_get_hmac() to avoid kernel panic
Date: Fri, 21 Mar 2008 09:51:10 +0800
Message-ID: <47E3148E.1080205@cn.fujitsu.com>
References: <47E1FBE0.6030209@cn.fujitsu.com> <47E2567C.7080105@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56337 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752436AbYCUBt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 21:49:57 -0400
In-Reply-To: <47E2567C.7080105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad:

Vlad Yasevich wrote:
> Hi Wei
>
> Wei Yongjun wrote:
>> If association is setup with HMAC-ALGO parameter in which there is no 
>> HMAC algorithm supported by the endpoint, send a chunk with AUTH will 
>> cause kernel panic.
>>
>> This is because  when send chunk with AUTH, sctp_auth_asoc_get_hmac() 
>> will be used to get the hmac. In this function, if the HMAC-ALGO is 
>> empty, it return NULL. If is not empty, it will find a valid hmac for 
>> using. But if all of the HMAC-ALGOs is not supported by endpoint, it 
>> will return a bogus pointer, not expected NULL pointer.
>
> This is a workaround, but this problem must never never happen.

This can happened under attack. I have a test case to found this problem.

> RFC 4890 has the following text:
>
>   The HMAC algorithm based on SHA-1 MUST be supported and
>   included in the HMAC-ALGO parameter.
>
> As a result, we need to check in sctp_verify_param() that HMAC_SHA1 is
> present in the list.  If not, we should probably treat this as a protocol
> violation.
>
> It should also be a protocol violation if the HMAC parameter is empty.

Agree, I will make a patch to fix this.

>
> That could almost remove the need for the sctp-auth_asoc_get_hmac() 
> function.

If we do the above check, this function can be removed. I do a test 
after the new patch is create.


