From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v4] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 14:20:38 +0100
Message-ID: <CAKv+Gu_jdiQn+o5PAZmPfMsQYt8PsOkDE6YNU11VH9WM_QPcvg@mail.gmail.com>
References: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net>
 <CAKv+Gu-aZhCBvnEQoZUZLDPXCrvgxO1pSd=6EHz+tMB+dFz5hg@mail.gmail.com>
 <1476696226.19992.13.camel@sipsolutions.net> <CAKv+Gu_ZH9hO_xbVfOfk90CxFJ6ZTz3PKWB1v23LRVzpBrb=oQ@mail.gmail.com>
 <1476696918.19992.15.camel@sipsolutions.net> <67161BCC-596E-4DDE-A58E-9195BB5570C2@linaro.org>
 <1476698041.19992.19.camel@sipsolutions.net> <41D0AC2F-E86E-4A98-AD8B-1239D7E6123A@linaro.org>
 <CAKv+Gu9OT6r3gbrLi_wzBcPXoA6K9z=-4ybrgQy4X=FvjOOuhA@mail.gmail.com> <1476710169.315.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476710169.315.1.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17 October 2016 at 14:16, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Mon, 2016-10-17 at 14:06 +0100, Ard Biesheuvel wrote:
>>
>> Actually, while I think it will be worthwhile going forward to
>> implement such an 'auxiliary data' feature in a generic way, I still
>> think we should address the issue at hand without too much
>> complication.
>>
>> If we pedal back to the version of 'mac80211: move struct aead_req
>> off the stack' that uses kzalloc() instead of aead_request_alloc(),
>> we can simply add some space for aad[] and/or zero[], and get rid of
>> the kmem cache entirely.
>>
>> If you're past this point already, i won't bother but otherwise I can
>> rework 'mac80211: move struct aead_req off the stack' so that the
>> other patch is no longer required (and IIRC, this is actually
>> something you proposed yourself a couple of iterations ago?)
>
> Yes, I did consider that.
>
> It makes some sense, and I guess the extra memcpy() would be cheaper
> than the extra alloc?
>
> I'd happily use that instead of the combination of my two patches. The
> aead_request_alloc() is just a simple inline anyway, so no real problem
> not using it.
>

Indeed. And it keeps the clutter inside the aes_xxx.c files, which
could easily be updated in the future to use some auxdata feature if
it ever materializes.

I think it would help this code, but also the ESP code you pointed
out, to have some kind of 'ordered synchronous' CRYPTO_xxx flag, where
the crypto API could manage the kmem cache and percpu pointers to
allocations. This goes well beyond what we can do as a fix, though, so
we need an intermediate solution in any case.

Shall I propose the patch?
