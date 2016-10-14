From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] mac80211: aes_ccm: move struct aead_req off the stack
Date: Fri, 14 Oct 2016 15:22:50 +0100
Message-ID: <7531788D-2651-449B-9824-E418F773F23C@linaro.org>
References: <1476450540-1760-1-git-send-email-ard.biesheuvel@linaro.org> <1476450635.31114.42.camel@sipsolutions.net> <CAKv+Gu_eS-C84rH_MLYy--ivC0a99wwJvNDLhETfrBkYXW-XpA@mail.gmail.com> <1476450941.31114.45.camel@sipsolutions.net> <CAKv+Gu81RYq1aZUQ2Aru3Vev4LGgb1zFwWz8gepE0tQEhQi9Uw@mail.gmail.com> <1476452792.31114.46.camel@sipsolutions.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jouni Malinen <j@w1.fi>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476452792.31114.46.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> On 14 Oct 2016, at 14:46, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:=

>=20
>=20
>>=20
>> Is the aad[] actually reused? I would assume it only affects the mac
>> on encryption, and the verification on decryption but I don't think
>> we actually need it back from the crypto routines.
>=20
> I don't think it's reused.
>=20
>> Exactly what you said above :-) My patch only touches CCM but as you
>> said,
>>=20
>> """
>> 'Also there's B_0/J_0 for CCM/GCM, and the 'zero' thing that GMAC
>> has.
>> """
>=20
> Ah, but we can/should do the same for the others, no?
>=20

Yes, but then we end up kmalloc/kfreeing chunks of 16 bytes, which is actual=
ly another problem.

I still think we are not violating the api by putting aead_req on the stack (=
but herbert should confirm). The aad[] issue does violate the api, so it des=
erves a separate fix imo=
