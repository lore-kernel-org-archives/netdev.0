From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] isdn: hisax: isac: fixed code style issues.
Date: Sun, 13 Mar 2016 12:31:33 -0700
Message-ID: <1457897493.11972.55.camel@perches.com>
References: <1457896913-5406-1-git-send-email-gabrielcsmo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Cosmin-Gabriel Samoila <gabrielcsmo@gmail.com>, isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457896913-5406-1-git-send-email-gabrielcsmo@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-03-13 at 21:21 +0200, Cosmin-Gabriel Samoila wrote:
> Fixed errors and warnings reported by checkpatch.pl.

Generally it's better to send multiple patches that each
change a specific type of style defect.

As is, this patch changes object code.
=46ixing style inconsistency should not do that.

> diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
[]
> @@ -24,9 +24,8 @@
> =A0#define DBUSY_TIMER_VALUE 80
> =A0#define ARCOFI_USE 1
> =A0
> -static char *ISACVer[] =3D
> -{"2086/2186 V1.1", "2085 B1", "2085 B2",
> - "2085 V2.3"};
> +static char *ISACVer[] =3D {"2086/2186 V1.1", "2085 B1", "2085 B2",
> +"2085 V2.3"};

Most common kernel style would use:

static const char *ISACVer[] =3D {
	"2086/2186 V1.1", "2085 B1", "2085 B2", "2085 V2.3"
};

> @@ -251,11 +252,12 @@ isac_interrupt(struct IsdnCardState *cs, u_char=
 val)
> =A0				cs->tx_skb =3D NULL;
> =A0			}
> =A0		}
> -		if ((cs->tx_skb =3D skb_dequeue(&cs->sq))) {
> +		cs->tx_skb =3D skb_dequeue(&cs->sq);
> +		if (cs->tx_skb) {
> =A0			cs->tx_cnt =3D 0;
> =A0			isac_fill_fifo(cs);
> -		} else
> -			schedule_event(cs, D_XMTBUFREADY);
> +		}
> +		schedule_event(cs, D_XMTBUFREADY);

This changes object code.
