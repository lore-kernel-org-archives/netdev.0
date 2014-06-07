From: Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] dns_resolver: assure that dns_query() result is null-terminated
Date: Sat, 7 Jun 2014 14:54:56 -0400
Message-ID: <CAHQdGtTtwS_DAXx-nhVjjO3D1wksuV+5br10gX0DheHzWDD+sw@mail.gmail.com>
References: <1402163811-21604-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Miller David S." <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel mailing list <linux-kernel@vger.kernel.org>
To: =?UTF-8?Q?Manuel_Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402163811-21604-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 7, 2014 at 1:56 PM, Manuel Sch=C3=B6lling
<manuel.schoelling@gmx.de> wrote:
> dns_query() credulously assumes that keys are null-terminated and
> returns a copy of a memory block that is off by one.
> ---
>  net/dns_resolver/dns_query.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_quer=
y.c
> index e7b6d53..53be635 100644
> --- a/net/dns_resolver/dns_query.c
> +++ b/net/dns_resolver/dns_query.c
> @@ -149,7 +149,9 @@ int dns_query(const char *type, const char *name,=
 size_t namelen,
>         if (!*_result)
>                 goto put;
>
> -       memcpy(*_result, upayload->data, len + 1);
> +       memcpy(*_result, upayload->data, len);
> +       *_result[len+1] =3D '\0';

Off by one...

> +
>         if (_expiry)
>                 *_expiry =3D rkey->expiry;
>
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--=20
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
