From: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Mon, 19 Dec 2016 17:19:16 +0000
Message-ID: <CAGiyFdf9vV+WikAsxG0m9UkGC1ggjJjkwGWzYwvxxNNeangwBg@mail.gmail.com>
References: <20161215203003.31989-1-Jason@zx2c4.com> <20161215203003.31989-2-Jason@zx2c4.com>
 <CAH8yC8nE5CLfbv8gCRCeiNW3JLCAB3062-6pNO8mEXJYcsFUsw@mail.gmail.com> <CAHmME9o6CFuQJEp3QJgkh78r5Z2F8NJnpTCCFUiSnAiJxPGCJQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=f403045ec27e3cffea0544061f82
Cc: Netdev <netdev@vger.kernel.org>, kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linus Torvalds <torvalds@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>, George Spelvin <linux@sciencehorizons.net>,
	Vegard Nossum <vegard.nossum@gmail.com>, Andi Kleen <ak@linux.intel.com>,
	David Miller <davem@davemloft.net>, Andy Lutomirski <luto@amacapital.net>,
	"Daniel J . Bernstein" <djb@cr.yp.to>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, noloader@gmail.com
Return-path: <kernel-hardening-return-5701-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9o6CFuQJEp3QJgkh78r5Z2F8NJnpTCCFUiSnAiJxPGCJQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

--f403045ec27e3cffea0544061f82
Content-Type: text/plain; charset=UTF-8

Yeah you can use the PRF properties to build a DRBG, but that may not be
optimal in terms of performance.
On Mon, 19 Dec 2016 at 18:08, Jason A. Donenfeld <Jason@zx2c4.com> wrote:

> On Sat, Dec 17, 2016 at 3:55 PM, Jeffrey Walton <noloader@gmail.com>
> wrote:
> > It may be prudent to include the endian reversal in the test to ensure
> > big endian machines produce expected results. Some closely related
> > testing on an old Apple PowerMac G5 revealed that result needed to be
> > reversed before returning it to a caller.
>
> The function [1] returns a u64. Originally I had it returning a
> __le64, but that was considered unnecessary by many prior reviewers on
> the list. It returns an integer. If you want uniform bytes out of it,
> then use the endian conversion function, the same as you would do with
> any other type of integer.
>
> Additionally, this function is *not* meant for af_alg or any of the
> crypto/* code. It's very unlikely to find a use there.
>
>
> > Forgive my ignorance... I did not find reading on using the primitive
> > in a PRNG. Does anyone know what Aumasson or Bernstein have to say?
> > Aumasson's site does not seem to discuss the use case:
>
> He's on this thread so I suppose he can speak up for himself. But in
> my conversations with him, the primary take-away was, "seems okay to
> me!". But please -- JP - correct me if I've misinterpreted.
>

--f403045ec27e3cffea0544061f82
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Yeah you can use the PRF properties to build a DRBG, but that may not be op=
timal in terms of performance.<br><div class=3D"gmail_quote"><div dir=3D"lt=
r">On Mon, 19 Dec 2016 at 18:08, Jason A. Donenfeld &lt;<a href=3D"mailto:J=
ason@zx2c4.com">Jason@zx2c4.com</a>&gt; wrote:<br></div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">On Sat, Dec 17, 2016 at 3:55 PM, Jeffrey Walton &lt;<a href=
=3D"mailto:noloader@gmail.com" class=3D"gmail_msg" target=3D"_blank">noload=
er@gmail.com</a>&gt; wrote:<br class=3D"gmail_msg">
&gt; It may be prudent to include the endian reversal in the test to ensure=
<br class=3D"gmail_msg">
&gt; big endian machines produce expected results. Some closely related<br =
class=3D"gmail_msg">
&gt; testing on an old Apple PowerMac G5 revealed that result needed to be<=
br class=3D"gmail_msg">
&gt; reversed before returning it to a caller.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
The function [1] returns a u64. Originally I had it returning a<br class=3D=
"gmail_msg">
__le64, but that was considered unnecessary by many prior reviewers on<br c=
lass=3D"gmail_msg">
the list. It returns an integer. If you want uniform bytes out of it,<br cl=
ass=3D"gmail_msg">
then use the endian conversion function, the same as you would do with<br c=
lass=3D"gmail_msg">
any other type of integer.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
Additionally, this function is *not* meant for af_alg or any of the<br clas=
s=3D"gmail_msg">
crypto/* code. It&#39;s very unlikely to find a use there.<br class=3D"gmai=
l_msg">
<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
&gt; Forgive my ignorance... I did not find reading on using the primitive<=
br class=3D"gmail_msg">
&gt; in a PRNG. Does anyone know what Aumasson or Bernstein have to say?<br=
 class=3D"gmail_msg">
&gt; Aumasson&#39;s site does not seem to discuss the use case:<br class=3D=
"gmail_msg">
<br class=3D"gmail_msg">
He&#39;s on this thread so I suppose he can speak up for himself. But in<br=
 class=3D"gmail_msg">
my conversations with him, the primary take-away was, &quot;seems okay to<b=
r class=3D"gmail_msg">
me!&quot;. But please -- JP - correct me if I&#39;ve misinterpreted.<br cla=
ss=3D"gmail_msg">
</blockquote></div>

--f403045ec27e3cffea0544061f82--
