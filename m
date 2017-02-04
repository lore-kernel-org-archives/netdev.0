From: "Malinen, Jouni" <jouni@qca.qualcomm.com>
Subject: Re: [RFC PATCH 0/2] mac80211: use crypto shash for AES cmac
Date: Sat, 4 Feb 2017 14:39:16 +0000
Message-ID: <20170204143913.GA24691@jouni.qca.qualcomm.com>
References: <1486149955-11825-1-git-send-email-ard.biesheuvel@linaro.org>
 <20170203214707.GA14147@jouni.qca.qualcomm.com>
 <CAKv+Gu9zp+vptF2mHP5MW=x_K5m7WQgMxNNSD5hn93aT_-99xA@mail.gmail.com>
 <20170204113514.GA4350@jouni.qca.qualcomm.com>
 <CAKv+Gu9p_yng=_=sri8VtRpBCpvL-r1iZ=YgEqNhuQf55p1xBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:9406 "EHLO
        wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbdBDOjX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 09:39:23 -0500
In-Reply-To: <CAKv+Gu9p_yng=_=sri8VtRpBCpvL-r1iZ=YgEqNhuQf55p1xBA@mail.gmail.com>
Content-Language: en-US
Content-ID: <68517228D0BED54AA534075B64D22277@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 02:24:36PM +0000, Ard Biesheuvel wrote:
> There is another issue I spotted: the skcipher you allocate may be of
> the async variant, which may return from skcipher_encrypt() with
> -EINPROGRESS as soon as it has queued the request. Since you don't
> deal with that result, you should allocate a sync cipher explicitly:

> diff --git a/net/mac80211/fils_aead.c b/net/mac80211/fils_aead.c
> -       tfm2 =3D crypto_alloc_skcipher("ctr(aes)", 0, 0);
> +       tfm2 =3D crypto_alloc_skcipher("ctr(aes)", 0, CRYPTO_ALG_ASYNC);

> -       tfm2 =3D crypto_alloc_skcipher("ctr(aes)", 0, 0);
> +       tfm2 =3D crypto_alloc_skcipher("ctr(aes)", 0, CRYPTO_ALG_ASYNC);

Thanks! Can you send this as a full contribution or do you want me to
do that? I did run this through all the FILS test cases with
mac80211_hwsim.

> Thanks for the instructions and thanks for testing. If I manage to run
> this locally, I will follow up with an alternative patch #1 that
> switches FILS to use cmac(aes) as well (which looks reasonably
> feasible now that I understand the code)

If you have any issues in getting the hwsim test setup working, please
let me know. I'm trying to make it easy for anyone to run those tests in
hopes of improving quality of Linux WLAN contributions and what gets
applied into cfg80211 or mac80211 (or hostap.git for that matter). In
particular the latest step-by-step guide I added for the VM version (*)
was hoping to show how that can be done in 15 minutes from scratch..


(*) http://w1.fi/cgit/hostap/plain/tests/hwsim/vm/example-vm-setup.txt

--=20
Jouni Malinen                                            PGP id EFC895FA=
