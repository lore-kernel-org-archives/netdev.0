From: =?ISO-8859-1?Q?Andr=E9_Goddard_Rosa?= <andre.goddard@gmail.com>
Subject: Re: [dm-devel] [PATCH v4 00/12] introduce
	skip_spaces(), reducing code size plus some clean-ups
Date: Sun, 8 Nov 2009 14:52:18 -0200
Message-ID: <b8bf37780911080852l10d11f4ele5bf6a6aed94c5fe@mail.gmail.com>
References: <cover.1257602781.git.andre.goddard@gmail.com>
	<1257696303.4184.8.camel@mulgrave.site>
Reply-To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Pavel Roskin <proski@gnu.org>,
	Stefan Haberland <stefan.haberland@de.ibm.com>,
	Jan Kara <jack@suse.cz>, linux-cachefs@redhat.com,
	Mike Snitzer <snitzer@redhat.com>, Neil Brown <neilb@suse.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"James E . J . Bottomley" <jejb@parisc-linux.org>,
	ibm-acpi-devel@lists.sourceforge.net,
	device-mapper development <dm-devel@redhat.com>,
	Julia Lawall <julia@diku.dk>, "H . Peter Anvin" <hpa@zytor.com>,
	Daire Byrne <Daire.Byrne@framestore.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Banks <gnb@melbourne.sgi.com>,
	Stefan Weinhuber <wein@de.ibm.com>,
	Eric Sandeen <sandeen@redhat.com>, Adam Belay <abelay@mit.edu>,
	netfilter-devel@vger.kernel.org, Helge Deller <deller@gmx.de>,
	x86@kernel.org, James Morris <jmorris@namei.org>,
	Takashi Iwai <tiwai@suse.de>, Ing
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Return-path: <linux-cachefs-bounces@redhat.com>
In-Reply-To: <1257696303.4184.8.camel@mulgrave.site>
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

Hi, James!

On Sun, Nov 8, 2009 at 2:05 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Sat, 2009-11-07 at 13:16 -0200, Andr=E9 Goddard Rosa wrote:
>> This patch reduces lib.a code size by 173 bytes on my Core 2 with gcc =
4.4.1
>> even considering that it exports a newly defined function skip_spaces(=
)
>> to drivers:
>> =A0 =A0text =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 hex filename
>> =A0 64867 =A0 =A0 840 =A0 =A0 592 =A0 66299 =A0 102fb (TOTALS-lib.a-be=
fore)
>> =A0 64954 =A0 =A0 584 =A0 =A0 588 =A0 66126 =A0 1024e (TOTALS-lib.a-af=
ter)
>> and implements some code tidy up.
>>
>> Besides reducing lib.a size, it converts many in-tree drivers to use t=
he
>> newly defined function, which makes another small reduction on kernel =
size
>> overall when those drivers are used.
>
> Before we embark on something as massive as this, could we take a step
> back. =A0I agree that if I were coming up with the strstip() interface
> today I probably wouldn't have given it two overloaded uses.
>
> However, I think the function, in spite of this minor issue, is very
> usable. =A0I still don't understand why people thought adding a
> __must_check, which is what damaged one of the overloaded uses, is a
> good idea.

Differently of "static void strip(char *str)"@scripts/kconfig/conf.c ,
this function
does not moves the characters to the beginning of the string, so that if =
that
string is going to be reused it should refer to the newly returned string=
 start.

I've changed it to remove the const and return a "char *".

Do you think __must_check is not needed as well?

Thanks,
Andr=E9
