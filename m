From: Behan Webster <behanw@converseincode.com>
Subject: Re: [PATCH v2] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Sat, 08 Mar 2014 12:17:35 -0800
Message-ID: <531B7ADF.7030606@converseincode.com>
References: <1394177091.4653.1.camel@jlt4.sipsolutions.net>	 <1394241960-1764-1-git-send-email-behanw@converseincode.com>	 <1394243809.6972.4.camel@joe-AO722> <531A7D4F.7090303@converseincode.com> <1394245662.6972.12.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dwmw2@infradead.org, pageexec@freemail.hu,
	=?ISO-8859-1?Q?Jan-Simon_M=F6?= =?ISO-8859-1?Q?ller?=
	<dl9pf@gmx.de>,
	=?ISO-8859-1?Q?Vin=EDcius_Tinti?= <viniciustinti@gmail.com>,
	Mark Charlebois <charlebm@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394245662.6972.12.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/07/14 18:27, Joe Perches wrote:
> On Fri, 2014-03-07 at 18:15 -0800, Behan Webster wrote:
>> On 03/07/14 17:56, Joe Perches wrote:
>>> On Fri, 2014-03-07 at 17:26 -0800, behanw@converseincode.com wrote:
>>>> From: Jan-Simon M=F6ller <dl9pf@gmx.de>
>>>>
>>>> Replaced the use of a Variable Length Array In Struct (VLAIS) with=
 a C99
>>>> compliant equivalent. This is the original VLAIS struct.
>>> []
>>>> diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
>>> []
>>>> @@ -23,12 +23,14 @@ void ieee80211_aes_ccm_encrypt(struct crypto_a=
ead *tfm, u8 *b_0, u8 *aad,
>>>>    			       u8 *data, size_t data_len, u8 *mic)
>>>>    {
>>>>    	struct scatterlist assoc, pt, ct[2];
>>>> -	struct {
>>>> -		struct aead_request	req;
>>>> -		u8			priv[crypto_aead_reqsize(tfm)];
>>>> -	} aead_req;
>>>>   =20
>>>> -	memset(&aead_req, 0, sizeof(aead_req));
>>>> +	char aead_req_data[sizeof(struct aead_request) +
>>>> +				crypto_aead_reqsize(tfm) +
>>>> +				CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;
>>> Can this be a too large amount of stack?
>>>
>>> Is crypto_aead_reqsize() limited to < ~1k?
>>>
>>> Perhaps it'd be better to use kzalloc for this
>>> or another reserved pool
>> No more stack being used than with the the original code. The stack
>> memory use is identical.
> I do understand that, but that's not my question.
>
> I appreciate you're getting this to compile for llvm.
>
> Any idea of the max value of crypto_aead_reqsize?
And I understand your question, as well as why it is important.

Moving it from being stack based to alloacted memory may or may not be =
a=20
good thing, but is orthogonal to the intention of this particular patch=
=20
(which is just to remove the use of VLAIS from this code).

> $ grep-2.5.4 -rP --include=3D*.[ch] "(?:->|\.)\s*\breqsize\s*=3D[^=3D=
][^;]+;" *
Very clever. I'm going to use this. :)

Behan

--=20
Behan Webster
behanw@converseincode.com
