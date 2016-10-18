From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH 2/2] mac80211: aes_ccm: cache AEAD request
 structures per CPU
Date: Tue, 18 Oct 2016 16:24:07 +0200
Message-ID: <1476800647.6425.38.camel@sipsolutions.net>
References: <1476799713-16188-1-git-send-email-ard.biesheuvel@linaro.org>
         <1476799713-16188-3-git-send-email-ard.biesheuvel@linaro.org>
         <1476800194.6425.35.camel@sipsolutions.net>
         <CAKv+Gu8aE4AfewHeMDf2RQfJtSsrp6Fb1A_ygFsqEwpyP6hDjQ@mail.gmail.com>
         (sfid-20161018_161829_091999_FC9D3B10)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Jouni Malinen <j@w1.fi>, Andy Lutomirski <luto@amacapital.net>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56329 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753095AbcJROYL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 10:24:11 -0400
In-Reply-To: <CAKv+Gu8aE4AfewHeMDf2RQfJtSsrp6Fb1A_ygFsqEwpyP6hDjQ@mail.gmail.com> (sfid-20161018_161829_091999_FC9D3B10)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-18 at 15:18 +0100, Ard Biesheuvel wrote:
> 
> > Hmm. Is it really worth having a per-CPU variable for each possible
> > key? You could have a large number of those (typically three when
> > you're a client on an AP, and 1 + 1 for each client when you're the
> > AP).

2 + 1 for each client, actually, since you have 2 GTKs present in the
"steady state"; not a big difference though.

> > Would it be so bad to have to set the TFM every time (if that's
> > even possible), and just have a single per-CPU cache?

> That would be preferred, yes. The only snag here is that
> crypto_alloc_aead() is not guaranteed to return the same algo every
> time, which means the request size is not guaranteed to be the same
> either. This is a rare corner case, of course, but it needs to be
> dealt with regardless

Ah, good point. Well I guess you could allocate a bigger one it if it's
too small, but then we'd have to recalculate the size all the time
(which we already did anyway, but saving something else would be good).
Then we'd be close to just having a per-CPU memory block cache though.

johannes
