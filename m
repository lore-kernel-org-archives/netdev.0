From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] flow_dissector: Pre-initialize ip_proto in __skb_flow_dissect()
Date: Thu, 25 Jun 2015 09:07:44 -0700
Message-ID: <CALx6S36S-npOnqa0U4KZTRNXNihH-cFzW3S6ZowtW_0_L4Ck2A@mail.gmail.com>
References: <1435237832-28838-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435237832-28838-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 25, 2015 at 6:10 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> net/core/flow_dissector.c: In function =E2=80=98__skb_flow_dissect=E2=
=80=99:
> net/core/flow_dissector.c:132: warning: =E2=80=98ip_proto=E2=80=99 ma=
y be used uninitialized in this function
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> This may be a false positive, but the state machine in
> __skb_flow_dissect() is a bit hard to follow.
> As I believe it is controlled by a packet received from the network, =
the
> only safe thing to do is to pre-initialize ip_proto.
> ---
>  net/core/flow_dissector.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 476e5dda59e19822..2a834c6179b9973e 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -129,7 +129,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb=
,
>         struct flow_dissector_key_ports *key_ports;
>         struct flow_dissector_key_tags *key_tags;
>         struct flow_dissector_key_keyid *key_keyid;
> -       u8 ip_proto;
> +       u8 ip_proto =3D 0;
>
>         if (!data) {
>                 data =3D skb->data;
> --
> 1.9.1
>

Acked-by: Tom Herbert <tom@herbertland.com>
