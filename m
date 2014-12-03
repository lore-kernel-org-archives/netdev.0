From: David Miller <davem@davemloft.net>
Subject: Re: tun issue after e0b46d0ee9c: tun: Use iovec iterators
Date: Tue, 02 Dec 2014 20:54:44 -0800 (PST)
Message-ID: <20141202.205444.694919440847723773.davem@davemloft.net>
References: <5478CC27.9040705@redhat.com>
	<20141128235935.GA2178@gondor.apana.org.au>
	<20141130100331.GA10050@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaLCEu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 23:50:26 -0500
In-Reply-To: <20141130100331.GA10050@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 30 Nov 2014 18:03:31 +0800

> On Sat, Nov 29, 2014 at 07:59:35AM +0800, Herbert Xu wrote:
>> On Fri, Nov 28, 2014 at 05:25:27PM -0200, Marcelo Ricardo Leitner wrote:
>> > 
>> > I saw there are tun updates on Dave's queue but none seemed to handle this.
>> > 
>> > I can't use current net-next
>> > (799d2fff1858004526ad75d66a5dd8a5cce6ad40) on a kvm hypervisor
>> > because tun got clogged somehow. Bisected down to:
>> > 
>> > commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
>> > Author: Herbert Xu <herbert@gondor.apana.org.au>
>> > Date:   Fri Nov 7 21:22:23 2014 +0800
>> 
>> Does this patch help?
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

Applied, thanks.
