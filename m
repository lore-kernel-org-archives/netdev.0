From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH] Ceph: Fix a use-after-free bug in ceph_destroy_client().
Date: Sat, 25 Dec 2010 22:12:31 +0100
Message-ID: <AANLkTik+yrpY8T69w_RQ84ZbRqwkjvFhvxHLBvU14N3f@mail.gmail.com>
References: <alpine.LNX.2.00.1012251914370.10759@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ceph-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Sage Weil <sage@newdream.net>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:42939 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334Ab0LYVMd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 16:12:33 -0500
In-Reply-To: <alpine.LNX.2.00.1012251914370.10759@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 25, 2010 at 7:17 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> Hello,
>
> In net/ceph/ceph_common.c::ceph_destroy_client() the pointer 'client'=
 is
> freed by kfree() and subsequently used in a call to dout() - use afte=
r
> free bug.

Not really. %p reads only the address of "client".
kfree() does not alter this address.

> Easily fixed by simply moving the kfree() call after the dout() call.
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
> =A0ceph_common.c | =A0 =A02 +-
> =A01 file changed, 1 insertion(+), 1 deletion(-)
> diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
> index f3e4a13..890bbbf 100644
> --- a/net/ceph/ceph_common.c
> +++ b/net/ceph/ceph_common.c
> @@ -408,8 +408,8 @@ void ceph_destroy_client(struct ceph_client *clie=
nt)
>
> =A0 =A0 =A0 =A0ceph_destroy_options(client->options);
>
> - =A0 =A0 =A0 kfree(client);
> =A0 =A0 =A0 =A0dout("destroy_client %p done\n", client);
> + =A0 =A0 =A0 kfree(client);
> =A0}
> =A0EXPORT_SYMBOL(ceph_destroy_client);
>
>
> --
> Jesper Juhl <jj@chaosbits.net> =A0 =A0 =A0 =A0 =A0 =A0http://www.chao=
sbits.net/
> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>


--=20
Thanks,
//richard
