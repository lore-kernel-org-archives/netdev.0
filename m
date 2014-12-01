From: Jason Wang <jasowang@redhat.com>
Subject: Re: tun issue after e0b46d0ee9c: tun: Use iovec iterators
Date: Mon, 01 Dec 2014 05:41:00 +0008
Message-ID: <1417411980.7521.0@smtp.corp.redhat.com>
References: <5478CC27.9040705@redhat.com>
	<20141128235935.GA2178@gondor.apana.org.au>
	<20141130100331.GA10050@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55379 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627AbaLAFdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2014 00:33:08 -0500
In-Reply-To: <20141130100331.GA10050@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, Nov 30, 2014 at 6:03 PM, Herbert Xu 
<herbert@gondor.apana.org.au> wrote:
> On Sat, Nov 29, 2014 at 07:59:35AM +0800, Herbert Xu wrote:
>>  On Fri, Nov 28, 2014 at 05:25:27PM -0200, Marcelo Ricardo Leitner 
>> wrote:
>>  > 
>>  > I saw there are tun updates on Dave's queue but none seemed to 
>> handle this.
>>  > 
>>  > I can't use current net-next
>>  > (799d2fff1858004526ad75d66a5dd8a5cce6ad40) on a kvm hypervisor
>>  > because tun got clogged somehow. Bisected down to:
>>  > 
>>  > commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
>>  > Author: Herbert Xu <herbert@gondor.apana.org.au>
>>  > Date:   Fri Nov 7 21:22:23 2014 +0800
>>  
>>  Does this patch help?
> 
> Oops, there was an embarrassing typo in the patch which causes
> it to not even build.  Here is the corrected version.
> 
> -- >8 --
> Subject: tun: Fix GSO meta-data handling in tun_get_user
>     
> When we write the GSO meta-data in tun_get_user we end up advancing
> the IO vector twice, thus exhausting the user buffer before we can
> finish writing the packet.
>     
> Fixes: f5ff53b4d97c ("{macvtap,tun}_get_user(): switch to iov_iter")
> Reported-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 4b743c6..6d44da1 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1052,7 +1052,7 @@ static ssize_t tun_get_user(struct tun_struct 
> *tun, struct tun_file *tfile,
>  
>  		if (gso.hdr_len > len)
>  			return -EINVAL;
> -		iov_iter_advance(from, tun->vnet_hdr_sz);
> +		iov_iter_advance(from, tun->vnet_hdr_sz - sizeof(gso));
>  	}
>  
>  	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
> 

Acked-by: Jason Wang <jasowang@redhat.com>
