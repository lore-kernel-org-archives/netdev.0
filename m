From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v7 0/5] skb_to_sgvec hardening
Date: Tue, 09 May 2017 16:03:20 +0200
Message-ID: <1494338600.2410.6.camel@sipsolutions.net>
References: <20170509135009.13751-1-Jason@zx2c4.com>
         (sfid-20170509_155352_302082_2551EB62)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        kernel-hardening@lists.openwall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48328 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751210AbdEIODa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 10:03:30 -0400
In-Reply-To: <20170509135009.13751-1-Jason@zx2c4.com> (sfid-20170509_155352_302082_2551EB62)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-09 at 15:50 +0200, Jason A. Donenfeld wrote:
> The recent bug with macsec and historical one with virtio have
> indicated that letting skb_to_sgvec trounce all over an sglist
> without checking the length is probably a bad idea. And it's not
> necessary either: an sglist already explicitly marks its last
> item, and the initialization functions are diligent in doing so.
> Thus there's a clear way of avoiding future overflows.
> 
> So, this patchset, from a high level, makes skb_to_sgvec return
> a potential error code, and then adjusts all callers to check
> for the error code.

Perhaps you should add __must_check annotation to the function
prototype(s)?

johannes
