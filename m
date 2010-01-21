From: Li Yewang <lyw@cn.fujitsu.com>
Subject: Re: [PATCH][XFRM] Use the simple name when adding SAD with ip xfrm
 state
Date: Thu, 21 Jan 2010 13:22:17 +0800
Message-ID: <4B57E489.6010707@cn.fujitsu.com>
References: <20100119022033.GA18155@gondor.apana.org.au>	<4B556C72.40403@cn.fujitsu.com> <20100119.003041.193317921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51973 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750969Ab0AUFXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 00:23:14 -0500
In-Reply-To: <20100119.003041.193317921.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I am new to crypto.

I searched the soucre code in the directory of /crypto,
and found that, all cryptos use shortname, for example:

crypto/xcbc.c
static struct crypto_template crypto_xcbc_tmpl = {
        .name = "xcbc",
        .create = xcbc_create,
        .free = shash_free_instance,
        .module = THIS_MODULE,
};


The name such as rfc3686(ctr(aes)) only used by "ip xfrm state" command to set SAD.



David Miller wrote:
> From: Li Yewang <lyw@cn.fujitsu.com>
> Date: Tue, 19 Jan 2010 16:25:22 +0800
> 
>>
>> Herbert Xu wrote:
>>> Li Yewang <lyw@cn.fujitsu.com> wrote:
>>>> The encryption name such as "rfc3686(ctr(aes))" is too complex.
>>>> I think simple name is better for user when using "ip xfrm state ..." command.
>>>>
>>>>
>>>> Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>
>>> Nack.  If we want to support simple names such as these, they
>>> should be done in the crypto layer.  Otherwise every crypto user
>>> that wants this would have to reinvent it.
>>   But user sets SAD for ipsec with "ip xfrm state ..." must use the name such as "rfc3686(ctr(aes))".
>>   Is that reasonable? Maybe user can not remember this complex name.
>>
>>   There are some simple names for other encryptions, 
>>   such as "cbc(blowfish)", you can use "ip xfrm state ... enc blowfish ...".
> 
> You're not reading what Herbert is saying.
> 
> He's fine with the shorter name, he just wants you to implement
> is in the crypto layer core instead of the XFRM specific code.
> 
> That way all crypto users will benefit from the shorter naming.
> 
> 
> 

-- 
Regards
Li Yewang
--------------------------------------------------
Li Yewang
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China 
TEL: +86+25-86630566-888
COINS: 79955-888
FAX: +86+25-83317685
MAIL: lyw@cn.fujitsu.com
--------------------------------------------------

