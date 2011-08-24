From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: slow performance on disk/network i/o full speed after
 drop_caches
Date: Wed, 24 Aug 2011 17:32:05 +0800
Message-ID: <20110824093205.GA5214@localhost>
References: <4E5494D4.1050605@profihost.ag>
 <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pekka Enberg <penberg@kernel.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 24, 2011 at 02:20:07PM +0800, Pekka Enberg wrote:
> On Wed, Aug 24, 2011 at 9:06 AM, Stefan Priebe - Profihost AG
> <s.priebe@profihost.ag> wrote:
> > i hope this is the correct list to write to if it would be nice to gi=
ve me a
> > hint where i can ask.
> >
> > Kernel: 2.6.38
> >
> > I'm seeing some strange problems on some of our servers after upgradi=
ng to
> > 2.6.38.
> >
> > I'm copying a 1GB file via scp from Machine A to Machine B. When B is
> > freshly booted the file transfer is done with about 80 to 85 Mb/s. I =
can
> > repeat that various times to performance degrease.
> >
> > Then after some days copying is only done with about 900kb/s up to 3M=
b/s
> > going up and down while transfering the file.
> >
> > When i then do drop_caches it works again on 80Mb/s.
> >
> > sync && echo 3 >/proc/sys/vm/drop_caches && sleep 2 && echo 0
> >>/proc/sys/vm/drop_caches
> >
> > Attached is also an output of meminfo before and after drop_caches.
> >
> > What's going on here? MemFree is pretty high.
> >
> > Please CC me i'm not on list.
>=20
> Interesting. I can imagine one or more of the following to be
> involved: networking, vmscan, block, and writeback. Lets CC all of
> them!
>=20
> > # before drop_caches
> >
> > # cat /proc/meminfo
> > MemTotal: =C2=A0 =C2=A0 =C2=A0 =C2=A08185544 kB
> > MemFree: =C2=A0 =C2=A0 =C2=A0 =C2=A0 6670292 kB
> > Buffers: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0105164 kB
> > Cached: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 166672 kB
> > SwapCached: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 kB
> > Active: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 728308 kB
> > Inactive: =C2=A0 =C2=A0 =C2=A0 =C2=A0 567428 kB
> > Active(anon): =C2=A0 =C2=A0 639204 kB
> > Inactive(anon): =C2=A0 394932 kB
> > Active(file): =C2=A0 =C2=A0 =C2=A089104 kB
> > Inactive(file): =C2=A0 172496 kB
> > Unevictable: =C2=A0 =C2=A0 =C2=A0 =C2=A02976 kB
> > Mlocked: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02992 kB
> > SwapTotal: =C2=A0 =C2=A0 =C2=A0 1464316 kB
> > SwapFree: =C2=A0 =C2=A0 =C2=A0 =C2=A01464316 kB
> > Dirty: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A052 kB
> > Writeback: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB

Since dirty/writeback pages are low, it seems not being throttled by
balance_dirty_pages().

Stefan, would you please run this several times on the server?

ps -eo user,pid,tid,class,rtprio,ni,pri,psr,pcpu,vsz,rss,pmem,stat,wchan:=
28,cmd | grep scp

It will show where the scp task is blocked (the wchan field). Hope it hel=
ps.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
