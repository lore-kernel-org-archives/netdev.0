From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 1/2] macvlan: Fix potential use-after free for
 broadcasts
Date: Wed, 1 Jun 2016 12:27:19 +0800
Message-ID: <20160601042719.GA31691@gondor.apana.org.au>
References: <20160526234433.GU8402@wantstofly.org>
 <20160530081752.GA4956@gondor.apana.org.au>
 <20160530082828.GB5106@gondor.apana.org.au>
 <20160531.140713.2187659962450926738.davem@davemloft.net>
 <20160601034218.GA31335@gondor.apana.org.au>
 <20160601034300.GB31335@gondor.apana.org.au>
 <CAM_iQpVbo7cfuura=FC4gJimnjLx1gy=4HWe9QmSwzEZT9254Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:43813 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbcFAE13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 00:27:29 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpVbo7cfuura=FC4gJimnjLx1gy=4HWe9QmSwzEZT9254Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 31, 2016 at 09:19:37PM -0700, Cong Wang wrote:
>
> Hmm, why could this happen? The upper device should be linked
> with the lower device, where a refcount is already held.
> Also, the work is cancelled in ->uninit().

Of course it can happen.  We are talking about the source macvlan
device that we just looked up using the Ethernet address.  That
device has nothing to do with the packet now so it may be deleted
at any time.

We do flush the work but only when the all macvlan devices on a
port have been deleted.  Perhaps you're confusing the source
device with vlan->lowerdev which is confusingly the actual
hardware device?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
