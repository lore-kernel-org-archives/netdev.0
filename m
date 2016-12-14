From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 3/4] secure_seq: use siphash24 instead of md5_transform
Date: Wed, 14 Dec 2016 20:38:06 +0100
Message-ID: <CAHmME9rp2oSCo0eu92jKm00S0eJHz65bJKXRpeS7=_EV6zZNYw@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214035927.30004-3-Jason@zx2c4.com>
 <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com>
 <20161214.125612.1361254098267633173.davem@davemloft.net> <CAHmME9pz4XudfeqhKBwFNDmp7AYuNwbnevMqB3e6ScPDnUnq9g@mail.gmail.com>
 <0e708ba2-6a4e-013e-597a-62ab32cc240b@stressinduktion.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, David Laight <David.Laight@aculab.com>,
	Netdev <netdev@vger.kernel.org>, kernel-hardening@lists.openwall.com,
	Andi Kleen <ak@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <kernel-hardening-return-5538-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <0e708ba2-6a4e-013e-597a-62ab32cc240b@stressinduktion.org>
List-Id: netdev.vger.kernel.org

Hi Hannes,

On Wed, Dec 14, 2016 at 8:22 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> I don't think this helps. Did you test it? I don't see reason why
> padding could be left out between `d' and `end' because of the flexible
> array member?

Because the type u8 doesn't require any alignment requirements, it can
nestle right up there cozy with the u16:

zx2c4@thinkpad ~ $ cat a.c
#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
int main()
{
       struct {
               uint64_t a;
               uint32_t b;
               uint32_t c;
               uint16_t d;
               char x[];
       } a;
       printf("%zu\n", sizeof(a));
       printf("%zu\n", offsetof(typeof(a), x));
       return 0;
}
zx2c4@thinkpad ~ $ gcc a.c
zx2c4@thinkpad ~ $ ./a.out
24
18

Jason
