From: =?iso-8859-1?Q?Kelleter=2C_G=FCnther?= <GKelleter@datus.com>
Subject: Re: [PATCH] X.25: Fix address field length calculation
Date: Wed, 16 Oct 2013 06:58:46 +0000
Message-ID: <525E3925.7070105@datus.com>
References: <525D5131.9070007@datus.com>
 <1381858190.22110.25.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "andrew.hendry@gmail.com" <andrew.hendry@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-x25@vger.kernel.org" <linux-x25@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381858190.22110.25.camel@joe-AO722>
Content-Language: de-DE
Content-ID: <65BC7EDC9053D742822A7DCB7E3BEB4F@datus.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 15.10.2013 19:29, schrieb Joe Perches:
> On Tue, 2013-10-15 at 14:29 +0000, Kelleter, G=FCnther wrote:
>> Addresses are BCD encoded, not ASCII. x25_addr_ntoa got it right.
> []
>> Wrong length calculation leads to rejection of CALL ACCEPT packets.
> []
>> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> []
>> @@ -98,7 +98,7 @@ int x25_parse_address_block(struct sk_buff *skb,
>>  	}
>>   	len =3D *skb->data;
>> -	needed =3D 1 + (len >> 4) + (len & 0x0f);
>> +	needed =3D 1 + ((len >> 4) + (len & 0x0f) + 1) / 2;
> This calculation looks odd.
> Perhaps use bcd.h instead?
>

It's just the same calculation as in x25_add_ntoa (last line) and it's
used this way by x.25.
Two digits are encoded to one byte and the last byte is padded with 0 i=
f
the total number of digits is odd.--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
