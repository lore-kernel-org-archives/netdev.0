From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH v4 12/12] tree-wide: convert open calls
	to remove spaces to skip_spaces() lib function
Date: Sun, 8 Nov 2009 13:47:22 -0500
Message-ID: <20091108184722.GA1647@mit.edu>
References: <cover.1257602781.git.andre.goddard@gmail.com>
	<7d5883637aa976b54e944998f635d47a41618a75.1257602781.git.andre.goddard@gmail.com>
Reply-To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Pavel Roskin <proski@gnu.org>,
	Stefan Haberland <stefan.haberland@de.ibm.com>,
	Jan Kara <jack@suse.cz>, linux-cachefs@redhat.com,
	Mike Snitzer <snitzer@redhat.com>, Neil Brown <neilb@suse.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"James E . J . Bottomley" <jejb@parisc-linux.org>,
	ibm-acpi-devel@lists.sourceforge.net, dm-devel@redhat.com,
	Julia Lawall <julia@diku.dk>, "H . Peter Anvin" <hpa@zytor.com>,
	Daire Byrne <Daire.Byrne@framestore.com>,
	Alasdair G Kergon <agk@redhat.com>, Greg Banks <gnb@melbourne.sgi.com>,
	Stefan Weinhuber <wein@de.ibm.com>,
	Eric Sandeen <sandeen@redhat.com>, Adam Belay <abelay@mit.edu>,
	Helge Deller <deller@gmx.de>, x86@kernel.org,
	James Morris <jmorris@namei.org>, Takashi Iwai <tiwai@suse.de>,
	Ingo Molnar <mingo@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk
To: =?iso-8859-1?Q?Andr=E9?= Goddard Rosa <andre.goddard@gmail.com>
Return-path: <linux-cachefs-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <7d5883637aa976b54e944998f635d47a41618a75.1257602781.git.andre.goddard@gmail.com>
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

On Sat, Nov 07, 2009 at 01:16:20PM -0200, Andr=E9 Goddard Rosa wrote:
> Makes use of skip_spaces() defined in lib/string.c for removing leading
> spaces from strings all over the tree.
>=20
> Also, while at it, if we see (*str && isspace(*str)), we can be sure to
> remove the first condition (*str) as the second one (isspace(*str)) als=
o
> evaluates to 0 whenever *str =3D=3D 0, making it redundant. In other wo=
rds,
> "a char equals zero is never a space".

There are a number of places that have the pattern of skipping
whitespace, calling simpler_strtoul(), and then skipping whitespace
afterwards.  And thinkpad_acpi.c and fs/ext4/super.c both have an
indentical function, parse_strotul(), which basically does this plus
doing actual error checking (a number of callers of simple_strtoul
aren't checking to see if the user passed in a valid number or not,
boo.)

I would suggest that we should lift parse_strtoul() into lib/, both to
save a bit of code, as well as encouraging people to do proper input
validation, while we are doing this tree-wide cleanup.

						- Ted
