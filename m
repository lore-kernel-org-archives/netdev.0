From: Harsh Jain <Harsh@chelsio.com>
Subject: Re: [PATCH v1 3/8] crypto:chcr- Fix key length for RFC4106
Date: Thu, 12 Jan 2017 22:08:46 +0530
Message-ID: <648404c5-4234-7895-d478-858433b0d093@chelsio.com>
References: <cover.1483599449.git.harsh@chelsio.com>
 <6d8e61299e051d51dacdb6bfd6c5e582b230027c.1483599449.git.harsh@chelsio.com>
 <20170112160959.GA19732@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38122 "EHLO l.chelsio.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750791AbdALQi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 11:38:59 -0500
In-Reply-To: <20170112160959.GA19732@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12-01-2017 21:39, Herbert Xu wrote:
> On Fri, Jan 06, 2017 at 02:01:34PM +0530, Harsh Jain wrote:
>> Check keylen before copying salt to avoid wrap around of Integer.
>>
>> Signed-off-by: Harsh Jain <harsh@chelsio.com>
>> ---
>>  drivers/crypto/chelsio/chcr_algo.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
>> index deec7c0..6c2dea3 100644
>> --- a/drivers/crypto/chelsio/chcr_algo.c
>> +++ b/drivers/crypto/chelsio/chcr_algo.c
>> @@ -2194,8 +2194,8 @@ static int chcr_gcm_setkey(struct crypto_aead *aead, const u8 *key,
>>  	unsigned int ck_size;
>>  	int ret = 0, key_ctx_size = 0;
>>  
>> -	if (get_aead_subtype(aead) ==
>> -	    CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106) {
>> +	if (get_aead_subtype(aead) == CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106 &&
>> +	    keylen > 3) {
>>  		keylen -= 4;  /* nonce/salt is present in the last 4 bytes */
>>  		memcpy(aeadctx->salt, key + keylen, 4);
>>  	}
> We should return an error in this case.
That case is already handled in next if condition.It will error out with -EINVAL in next condition.

if (keylen == AES_KEYSIZE_128) {

>
> Cheers,
