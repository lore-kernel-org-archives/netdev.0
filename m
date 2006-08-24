From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 16/44] [XFRM] IPV6: Restrict bundle reusing
Date: Thu, 24 Aug 2006 11:54:45 +0900
Message-ID: <44ED14F5.3090709@linux-ipv6.org>
References: <11563453663761-git-send-email-yoshfuji@linux-ipv6.org>	<11563453662321-git-send-email-yoshfuji@linux-ipv6.org>	<11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <20060823.191214.10297360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:212 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1030215AbWHXCyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 22:54:25 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060823.191214.10297360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Thu, 24 Aug 2006 00:02:17 +0900
> 
>> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
>>
>> For outbound transformation, bundle is checked whether it is
>> suitable for current flow to be reused or not. In such IPv6 case
>> as below, transformation may apply incorrect bundle for the flow instead
>> of creating another bundle:
>>
>> - The policy selector has destination prefix length < 128
>>   (Two or more addresses can be matched it)
>> - Its bundle holds dst entry of default route whose prefix length < 128
>>   (Previous traffic was used such route as next hop)
>> - The policy and the bundle were used a transport mode state and
>>   this time flow address is not matched the bundled state.
>>
>> This issue is found by Mobile IPv6 usage to protect mobility signaling
>> by IPsec, but it is not a Mobile IPv6 specific.
>> This patch adds strict check to xfrm_bundle_ok() for each
>> state mode and address when prefix length is less than 128.
>>
>> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Applied.  Maybe ipv4 side wants to check for prefix length < 32?
> Or does it not matter for some reason under ipv4?

Logically yes. But I was not clear IPv4 __xfrm4_find_bundle()
has no prefix check as opposed to IPv6 one then I couldn't include it.


-- 
Masahide NAKAMURA
