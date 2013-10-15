From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] X.25: Fix address field length calculation
Date: Tue, 15 Oct 2013 10:29:50 -0700
Message-ID: <1381858190.22110.25.camel@joe-AO722>
References: <525D5131.9070007@datus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "andrew.hendry@gmail.com" <andrew.hendry@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-x25@vger.kernel.org" <linux-x25@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Kelleter," =?ISO-8859-1?Q?G=FCnther?= <GKelleter@datus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <525D5131.9070007@datus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-10-15 at 14:29 +0000, Kelleter, G=FCnther wrote:
> Addresses are BCD encoded, not ASCII. x25_addr_ntoa got it right.
[]
> Wrong length calculation leads to rejection of CALL ACCEPT packets.
[]
> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
[]
> @@ -98,7 +98,7 @@ int x25_parse_address_block(struct sk_buff *skb,
>  	}
>   	len =3D *skb->data;
> -	needed =3D 1 + (len >> 4) + (len & 0x0f);
> +	needed =3D 1 + ((len >> 4) + (len & 0x0f) + 1) / 2;

This calculation looks odd.
Perhaps use bcd.h instead?
