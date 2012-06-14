From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 2/5] drivers/net/ethernet/dec/tulip: Use standard
 __set_bit_le() function
Date: Thu, 14 Jun 2012 18:36:42 +0900
Message-ID: <CAC5umyjkdDqavCo3Dk+WOggCnH+_CZz5jrOr3SougS4HSgV3OA@mail.gmail.com>
References: <20120613130054.b5695621.yoshikawa.takuya@oss.ntt.co.jp>
	<20120613130304.0186fa9d.yoshikawa.takuya@oss.ntt.co.jp>
	<CAC5umyj582T+9GbOYDzOAanmMcVZ-Fdxr7i-8GWf3gTSmtAKUA@mail.gmail.com>
	<20120613214157.0a5179d5358ec7f1b2646606@gmail.com>
	<CAC5umygutE35hVObuooWj=ADP6PZDy4cqLtxGnRtxRX8uTtGSw@mail.gmail.com>
	<20120613230013.3cc59bf908616e94bb4ccef2@gmail.com>
	<CAP6odji_JvRkJP1dSzGK5ww3y71h4k6pXyj4pOQBpqP-X7Nn-A@mail.gmail.com>
	<20120614072831.63845f6ddf024ece28e49f5e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grant Grundler <grantgrundler@gmail.com>,
	Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>,
	akpm@linux-foundation.org, bhutchings@solarflare.com,
	grundler@parisc-linux.org, arnd@arndb.de, benh@kernel.crashing.org,
	avi@redhat.com, mtosatti@redhat.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	kvm@vger.kernel.org
To: Takuya Yoshikawa <takuya.yoshikawa@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120614072831.63845f6ddf024ece28e49f5e@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/6/14 Takuya Yoshikawa <takuya.yoshikawa@gmail.com>:
> On Wed, 13 Jun 2012 08:21:18 -0700
> Grant Grundler <grantgrundler@gmail.com> wrote:
>
>> >> >> Should this hash_table be converted from u16 hash_table[32] to
>> >> >> DECLARE_BITMAP(hash_table, 16 * 32) to ensure that it is align=
ed
>> >> >> on long-word boundary?
>> >> >
>> >> > I think hash_table is already long-word aligned because it is p=
laced
>> >> > right after a pointer.
>> >>
>> >> I recommend converting to proper bitmap. =A0Because such an impli=
cit
>> >> assumption is easily broken by someone touching this function.
>> >
>> > Do you mean something like:
>> > =A0 =A0 =A0 =A0DECLARE_BITMAP(__hash_table, 16 * 32);
>> > =A0 =A0 =A0 =A0u16 *hash_table =3D (u16 *)__hash_table;
>> > ?
>> >
>> > Grant, what do you think about this?
>>
>> Hi Takuya,
>> two thoughts:
>> 1) while I agree with Akinobu and thank him for pointing out a
>> _potential_ alignment problem, this is a separate issue and your
>> existing patch should go in anyway. There are probably other drivers
>> with _potential_ alignment issues. Akinobu could get credit for
>> finding them by submitting patches after reviewing calls to set_bit
>> and set_bit_le() - similar to what you are doing now.
>
> I prefer approach 1.
>
> hash_table is local in build_setup_frame_hash(), so if further
> improvement is also required, we can do that locally there later.

This potential alignment problem is introduced by this patch.  Because
the original set_bit_le() in tulip driver can handle unaligned bitmap.
This is why I recommended it should be fixed in this patch.

But please just ignore me if I'm too much paranoid.  And I'll handle
this issue if no one wants to do it.
