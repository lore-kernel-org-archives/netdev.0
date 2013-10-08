From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 8 Oct 2013 14:00:31 +0200
Message-ID: <CAKv+Gu9-ddqyuGg=NDFoWzNko+0uMG_po6WnzTc7g3DAzx=_dQ@mail.gmail.com>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org>
	<1381233152.13359.10.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Patch Tracking <patches@linaro.org>, linville@tuxdriver.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:34361 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902Ab3JHMAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 08:00:33 -0400
Received: by mail-la0-f45.google.com with SMTP id eh20so6688140lab.4
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 05:00:32 -0700 (PDT)
In-Reply-To: <1381233152.13359.10.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 October 2013 13:52, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Tue, 2013-10-08 at 13:31 +0200, Ard Biesheuvel wrote:
>
> Hmm, thanks I guess. I'll need to review this in more detail, but I have
> a question first:
>
>> +     /* allocate the variable sized aead_request on the stack */
>> +     int l = DIV_ROUND_UP(crypto_aead_reqsize(tfm),
>> +                          sizeof(struct aead_request));
>> +     struct aead_request req[1 + l];
>
> This looks a bit odd, why round up first and then add one? Why even
> bother using a struct array rather than some local struct like
>
> struct {
>   struct aead_request req;
>   u8 data[crypto_aed_reqsize(tfm)];
> } req_data;
>
> or so?
>

Yes, that looks much better. I will put that in my v2, let me know if
you have more questions/comments.

BTW I should probably have mentioned that this is fully tested code:
my zd1211 works happily with it using pairwise CCMP with no
regressions in performance.


Cheers,
Ard.
