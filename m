From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [dm-devel] [PATCH v4 00/12] introduce
 skip_spaces(), reducing code size plus some clean-ups
Date: Sun, 08 Nov 2009 10:05:03 -0600
Message-ID: <1257696303.4184.8.camel@mulgrave.site>
References: <cover.1257602781.git.andre.goddard@gmail.com>
Reply-To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Pavel Roskin <proski@gnu.org>,
	Stefan Haberland <stefan.haberland@de.ibm.com>,
	Jan Kara <jack@suse.cz>, linux-cachefs@redhat.com,
	Mike Snitzer <snitzer@redhat.com>, Neil Brown <neilb@suse.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"James E . J . Bottomley" <jejb@parisc-linux.org>,
	ibm-acpi-devel@lists.sourceforge.net, Chr,
	Julia Lawall <julia@diku.dk>, "H . Peter Anvin" <hpa@zytor.com>,
	Daire Byrne <Daire.Byrne@framestore.com>,
	Alasdair G Kergon <agk@redhat.com>, Greg Banks <gnb@melbourne.sgi.com>,
	Stefan Weinhuber <wein@de.ibm.com>,
	Eric Sandeen <sandeen@redhat.com>, Adam Belay <abelay@mit.edu>,
	netfilter-devel@vger.kernel.org, Helge Deller <deller@gmx.de>,
	x86@kernel.org, James Morris <jmorris@namei.org>,
	Takashi Iwai <tiwai@suse.de>, Ingo Molnar <mingo@redhat.com>,
	Alan Cox <alan@l
To: device-mapper development <dm-devel@redhat.com>
Return-path: <linux-cachefs-bounces@redhat.com>
In-Reply-To: <cover.1257602781.git.andre.goddard@gmail.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-cachefs>
List-Post: <mailto:linux-cachefs@redhat.com>
List-Help: <mailto:linux-cachefs-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=subscribe>
Sender: linux-cachefs-bounces@redhat.com
Errors-To: linux-cachefs-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Sat, 2009-11-07 at 13:16 -0200, Andr=C3=A9 Goddard Rosa wrote:
> This patch reduces lib.a code size by 173 bytes on my Core 2 with gcc 4=
.4.1
> even considering that it exports a newly defined function skip_spaces()
> to drivers:
>    text    data     bss     dec     hex filename                       =
   =20
>   64867     840     592   66299   102fb (TOTALS-lib.a-before)
>   64954     584     588   66126   1024e (TOTALS-lib.a-after)
> and implements some code tidy up.
>=20
> Besides reducing lib.a size, it converts many in-tree drivers to use th=
e
> newly defined function, which makes another small reduction on kernel s=
ize
> overall when those drivers are used.

Before we embark on something as massive as this, could we take a step
back.  I agree that if I were coming up with the strstip() interface
today I probably wouldn't have given it two overloaded uses.

However, I think the function, in spite of this minor issue, is very
usable.  I still don't understand why people thought adding a
__must_check, which is what damaged one of the overloaded uses, is a
good idea.

Assuming there's a good answer to the above:

> + * skip_spaces - Removes leading whitespace from @s.
> + * @s: The string to be stripped.
> + *
> + * Returns a pointer to the first non-whitespace character in @s.
> + */
> +const char *skip_spaces(const char *str)

I don't think const return is a good idea because most functions will be
manipulating the string and using pointers that won't be const, so this
will generate a ton of 'initialization discards qualifiers from pointer
target type' ... so that leads to the question of whether this patch
series was actually compiled ...

James
