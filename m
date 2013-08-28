From: Francesco Fusco <ffusco@redhat.com>
Subject: Re: [PATCH net-next v2 1/2] ipv4: IP_TOS and IP_TTL can be specified
 as ancillary data
Date: Wed, 28 Aug 2013 09:56:32 +0200
Message-ID: <521DAD30.1010903@redhat.com>
References: <cover.1377257704.git.ffusco@redhat.com> <cover.1377257704.git.ffusco@redhat.com> <aaa7e0af2fe535ea5216e438b5f65db88dcef8b2.1377257704.git.ffusco@redhat.com> <20130827.145649.1682045616049011855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50108 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754685Ab3H1H4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 03:56:36 -0400
In-Reply-To: <20130827.145649.1682045616049011855.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2013 08:56 PM, David Miller wrote:
> From: Francesco Fusco <ffusco@redhat.com>
> Date: Fri, 23 Aug 2013 14:19:32 +0200
>
>>    - changed the icmp_cookie ttl field from __s16 to __u8.
>>      A value of 0 means that the TTL has not been specified
>
> Sorry, I have to ask you to change the ttl field type back to __s16
> and use "-1" to mean not-specified.
>
> Zero is a valid TTL setting and it means to not allow the
> packet to leave this host.

Actually setsockopt() does not allow a TTL value of zero:

 From net/ipv4/ip_sockglue.c::do_ip_setsockopt()
-----
case IP_TTL:
                 if (optlen < 1)
                         goto e_inval;
                 if (val != -1 && (val < 1 || val > 255))
                         goto e_inval;
                 inet->uc_ttl = val;
                 break;
---------

To make my patch consistent with the behavior of setsockopt() I also
do not accept a TTL of zero in the ancillary data:
+	if (val < 1 || val > 255)
+		return -EINVAL;

Therefore, if icmp_cookie->ttl has a value of 0, that could only mean
that the user has not specified the TTL.

I agree that could be somehow confusing to consider 0 as a non specified
TTL, and that -1 would be more clear. However, it seems to me that we 
end up using 1 more byte in a struct that is stored on the stack for
readability reasons.

> Please make this change and resubmit, thanks.

I can change the code as you requested despite what I wrote above,
let me know.

Thanks,
Francesco
