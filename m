From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] tun: Limit amount of queued packets per device
Date: Sun, 15 Feb 2009 11:15:06 +0800
Message-ID: <20090215031506.GA7749@gondor.apana.org.au>
References: <20090204104825.GA21257@gondor.apana.org.au> <E1LUfJt-0005ZQ-4D@gondolin.me.apana.org.au> <1234290825.25178.100.camel@bling> <20090212111313.GD13859@gondor.apana.org.au> <1234467301.25178.305.camel@bling>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37927 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752736AbZBODPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 22:15:17 -0500
Content-Disposition: inline
In-Reply-To: <1234467301.25178.305.camel@bling>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 12, 2009 at 12:35:01PM -0700, Alex Williamson wrote:
> 
> Current net-next-2.6 (v2.6.29-rc2-1715-g367681f).  I just reverified it
> with kvm-userspace (kvm-83-389-ga1efe3d).  The problem goes away if I
> patch -R commit 33dccbb.

Sorry, my fault for not testing the merged result.

tun: Fix merge error

When forward-porting the tun accounting patch I managed to break
the send path compltely by dropping the tun_get call.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4825c52..a1b0697 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -660,7 +660,7 @@ static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 			      unsigned long count, loff_t pos)
 {
 	struct file *file = iocb->ki_filp;
-	struct tun_struct *tun = file->private_data;
+	struct tun_struct *tun = tun_get(file);
 	ssize_t result;
 
 	if (!tun)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
