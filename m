From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues,
 indent, and testmgr build issues
Date: Thu, 24 Jan 2013 10:45:18 +0200
Message-ID: <20130124104518.13058kllaldbmoio@www.dalek.fi>
References: <1776726593.108228.1358952383104.JavaMail.root@elliptictech.com>
 <20130123173510.14986sla4qsstz8k@www.dalek.fi>
 <51000CEE.9060109@linux-ipv6.org> <51000EEF.7090308@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Tom St Denis <tstdenis@elliptictech.com>,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	linux-crypto@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-02.sanoma.fi ([158.127.18.162]:37637 "EHLO
	sd-mail-sa-02.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194Ab3AXIpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 03:45:22 -0500
In-Reply-To: <51000EEF.7090308@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>:

> YOSHIFUJI Hideaki wrote:
>> Jussi Kivilinna wrote:
>>
>>>>>> diff --git a/include/uapi/linux/pfkeyv2.h
>>>>>> b/include/uapi/linux/pfkeyv2.h
>>>>>> index 0b80c80..d61898e 100644
>>>>>> --- a/include/uapi/linux/pfkeyv2.h
>>>>>> +++ b/include/uapi/linux/pfkeyv2.h
>>>>>> @@ -296,6 +296,7 @@ struct sadb_x_kmaddress {
>>>>>>  #define SADB_X_AALG_SHA2_512HMAC    7
>>>>>>  #define SADB_X_AALG_RIPEMD160HMAC    8
>>>>>>  #define SADB_X_AALG_AES_XCBC_MAC    9
>>>>>> +#define SADB_X_AALG_AES_CMAC_MAC    10
>>>>>>  #define SADB_X_AALG_NULL        251    /* kame */
>>>>>>  #define SADB_AALG_MAX            251
>>>>>
>>>>> Should these values be based on IANA assigned IPSEC AH transform
>>>>> identifiers?
>>>>>
>>>>> https://www.iana.org/assignments/isakmp-registry/isakmp-registry.xml#isakmp-registry-6
>>>>
>>>> There is no CMAC entry apparently ... despite the fact that CMAC  
>>>> is a proposed RFC standard for IPsec.
>>>>
>>>> It might be safer to move that to 14 since it's currently  
>>>> unassigned and then go through whatever channels are required to  
>>>> allocate it.  Mostly this affects key setting.  So this means my  
>>>> patch would break AH_RSA setkey calls (which the kernel doesn't  
>>>> support anyways).
>>>>
>>>
>>> Problem seems to be that PFKEYv2 does not quite work with IKEv2,  
>>> and XFRM API should be used instead. There is new numbers assigned  
>>> for IKEv2:  
>>> https://www.iana.org/assignments/ikev2-parameters/ikev2-parameters.xml#ikev2-parameters-7
>>>
>>> For new SADB_X_AALG_*, I'd think you should use value from  
>>> "Reserved for private use" range. Maybe 250?
>>
>> We can choose any value unless we do not break existing
>> binaries.  When IKE used, the daemon is responsible
>> for translation.
>
> I meant, we can choose any values "if" we do not break ...
>

Ok, so giving '10' to AES-CMAC is fine after all?

And if I'd want to add Camellia-CTR and Camellia-CCM support, I can  
choose next free numbers from SADB_X_EALG_*?

-Jussi
