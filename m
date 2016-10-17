From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v4] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 11:23:46 +0200
Message-ID: <1476696226.19992.13.camel@sipsolutions.net>
References: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net>
         <CAKv+Gu-aZhCBvnEQoZUZLDPXCrvgxO1pSd=6EHz+tMB+dFz5hg@mail.gmail.com>
         (sfid-20161017_111430_166768_740CD0F3)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKv+Gu-aZhCBvnEQoZUZLDPXCrvgxO1pSd=6EHz+tMB+dFz5hg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20161017_111430_166768_740CD0F3)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> Apologies for going back and forth on this, but it appears there may
> be another way to deal with this.
> 
> First of all, we only need this handling for the authenticated data,

Are you sure b_0/j_0 aren't needed? We pass those
to aead_request_set_crypt(), and I wasn't sure what that really did
internally, perhaps like the internal data.

Testing with that on the stack does seem to work, in fact.

Surely we need zero for GMAC though, since we also put that into the sg
list. Thus for GMAC we definitely need 20+16 bytes, and since I round
up to a cacheline (at least on SMP) it doesn't really matter that we
could get 36 instead of the 48 I have now.

> and only for CCM and GCM, not CMAC (which does not use scatterlists
> at all, it simply calls the AES cipher directly)

I didn't modify CMAC, I think, only GMAC, which also uses scatterlists.

> So that leaves a fixed 20 bytes for GCM and fixed 32 bytes for CCM,

and 36 for GMAC :)

johannes
