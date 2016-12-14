From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 3/4] secure_seq: use siphash24 instead of md5_transform
Date: Wed, 14 Dec 2016 18:49:26 +0100
Message-ID: <CAHmME9oAnqC9dvgF8ZcJzNX70PsPHu0Nn++eexQvktUR_w8pHA@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214035927.30004-3-Jason@zx2c4.com>
 <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com>
 <1e502c6b-cda3-c46d-2535-fcfb58f443a9@stressinduktion.org>
 <CAHmME9o4NVi-MPeURio1Ga58rnW6JAGQdTg6scd+K3EZEf3RNA@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6DB023F7BD@AcuExch.aculab.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>, Netdev <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andi Kleen <ak@linux.intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <kernel-hardening-return-5520-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB023F7BD@AcuExch.aculab.com>
List-Id: netdev.vger.kernel.org

On Wed, Dec 14, 2016 at 3:47 PM, David Laight <David.Laight@aculab.com> wrote:
> Just remove the __packed and ensure that the structure is 'nice'.
> This includes ensuring there is no 'tail padding'.
> In some cases you'll need to put the port number into a 32bit field.

I'd rather not. There's no point in wasting extra cycles on hashing
useless data, just for some particular syntactic improvement. __packed
__aligned(8) will do what we want perfectly, I think.

> I'd also require that the key be aligned.

Yep, I'll certainly do this for the siphash24_aligned version in the v3.
