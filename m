From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH] Ceph: Fix use-after-free bug in ceph_messenger_destroy()
Date: Sat, 25 Dec 2010 22:14:30 +0100
Message-ID: <AANLkTi=O=rKgXMBgMDRFZCCUSkqvHhZ+DkstSzWASVfQ@mail.gmail.com>
References: <alpine.LNX.2.00.1012251908410.10759@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Sage Weil <sage@newdream.net>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012251908410.10759@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 25, 2010 at 7:11 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> Hi,
>
> In net/ceph/messenger.c::ceph_messenger_destroy() the pointer 'msgr' =
is
> freed by kfree() and subsequently used in a call to dout() - use afte=
r
> free bug.

As I sad before, %p reads only the address.

> Easily fixed by simply moving the kfree() call after the dout() call.
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
> =A0messenger.c | =A0 =A02 +-
> =A01 file changed, 1 insertion(+), 1 deletion(-)
> diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
> index b6ff4a1..26514a7 100644
> --- a/net/ceph/messenger.c
> +++ b/net/ceph/messenger.c
> @@ -2131,8 +2131,8 @@ void ceph_messenger_destroy(struct ceph_messeng=
er *msgr)
> =A0 =A0 =A0 =A0dout("destroy %p\n", msgr);
> =A0 =A0 =A0 =A0kunmap(msgr->zero_page);
> =A0 =A0 =A0 =A0__free_page(msgr->zero_page);
> - =A0 =A0 =A0 kfree(msgr);
> =A0 =A0 =A0 =A0dout("destroyed messenger %p\n", msgr);
> + =A0 =A0 =A0 kfree(msgr);
> =A0}
> =A0EXPORT_SYMBOL(ceph_messenger_destroy);
>
>
> --
> Jesper Juhl <jj@chaosbits.net> =A0 =A0 =A0 =A0 =A0 =A0http://www.chao=
sbits.net/
> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Thanks,
//richard
