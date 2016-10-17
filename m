From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v4] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 15:16:09 +0200
Message-ID: <1476710169.315.1.camel@sipsolutions.net>
References: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net>
         <CAKv+Gu-aZhCBvnEQoZUZLDPXCrvgxO1pSd=6EHz+tMB+dFz5hg@mail.gmail.com>
         <1476696226.19992.13.camel@sipsolutions.net>
         <CAKv+Gu_ZH9hO_xbVfOfk90CxFJ6ZTz3PKWB1v23LRVzpBrb=oQ@mail.gmail.com>
         <1476696918.19992.15.camel@sipsolutions.net>
         <67161BCC-596E-4DDE-A58E-9195BB5570C2@linaro.org>
         <1476698041.19992.19.camel@sipsolutions.net>
         <41D0AC2F-E86E-4A98-AD8B-1239D7E6123A@linaro.org>
         <CAKv+Gu9OT6r3gbrLi_wzBcPXoA6K9z=-4ybrgQy4X=FvjOOuhA@mail.gmail.com>
         (sfid-20161017_150649_562459_576A0780)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50405 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753616AbcJQNQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 09:16:16 -0400
In-Reply-To: <CAKv+Gu9OT6r3gbrLi_wzBcPXoA6K9z=-4ybrgQy4X=FvjOOuhA@mail.gmail.com> (sfid-20161017_150649_562459_576A0780)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-10-17 at 14:06 +0100, Ard Biesheuvel wrote:
> 
> Actually, while I think it will be worthwhile going forward to
> implement such an 'auxiliary data' feature in a generic way, I still
> think we should address the issue at hand without too much
> complication.
> 
> If we pedal back to the version of 'mac80211: move struct aead_req
> off the stack' that uses kzalloc() instead of aead_request_alloc(),
> we can simply add some space for aad[] and/or zero[], and get rid of
> the kmem cache entirely.
> 
> If you're past this point already, i won't bother but otherwise I can
> rework 'mac80211: move struct aead_req off the stack' so that the
> other patch is no longer required (and IIRC, this is actually
> something you proposed yourself a couple of iterations ago?)

Yes, I did consider that.

It makes some sense, and I guess the extra memcpy() would be cheaper
than the extra alloc?

I'd happily use that instead of the combination of my two patches. The
aead_request_alloc() is just a simple inline anyway, so no real problem
not using it.

johannes
