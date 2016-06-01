From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [v2 PATCH 1/2] macvlan: Fix potential use-after free for broadcasts
Date: Tue, 31 May 2016 21:19:37 -0700
Message-ID: <CAM_iQpVbo7cfuura=FC4gJimnjLx1gy=4HWe9QmSwzEZT9254Q@mail.gmail.com>
References: <20160526234433.GU8402@wantstofly.org> <20160530081752.GA4956@gondor.apana.org.au>
 <20160530082828.GB5106@gondor.apana.org.au> <20160531.140713.2187659962450926738.davem@davemloft.net>
 <20160601034218.GA31335@gondor.apana.org.au> <20160601034300.GB31335@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:34122 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755805AbcFAET5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 00:19:57 -0400
Received: by mail-yw0-f179.google.com with SMTP id c127so7699288ywb.1
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 21:19:57 -0700 (PDT)
In-Reply-To: <20160601034300.GB31335@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 31, 2016 at 8:43 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> When we postpone a broadcast packet we save the source port in
> the skb if it is local.  However, the source port can disappear
> before we get a chance to process the packet.
>

Hmm, why could this happen? The upper device should be linked
with the lower device, where a refcount is already held.
Also, the work is cancelled in ->uninit().
