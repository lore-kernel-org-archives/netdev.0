From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: do_IRQ: stack overflow: 872..
Date: Sat, 18 Dec 2004 12:12:09 +0100
Message-ID: <1103368330.3566.15.camel@localhost.localdomain>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	 <p73zn0ccaee.fsf@verdi.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Crazy AMD K7 <snort2004@mail.ru>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262185AbULRLIn@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <p73zn0ccaee.fsf@verdi.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Op za, 18-12-2004 te 08:50 +0100, schreef Andi Kleen:
> Crazy AMD K7 <snort2004@mail.ru> writes:
>=20
> > Hi!
> > I have found a few days ago strange messages in /var/log/messages
> > More than 10 times there was do_IRQ: stack overflow: (nimber).... f=
ollowed
> > with code. If need I can send all this data. I have run
> > ksymoops with only first 3 cases. Here is the first, the second and
> > the third are in attachment.
> > After that oopses my system continued to work.
>=20
> It's not really an oops, just a warning that stack space got quiet ti=
ght.
>=20
> The problem seems to be that the br netfilter code is nesting far too
> deeply and recursing several times. Looks like a design bug to me,
> it shouldn't do that.
>=20
> > uname uname -a
> > Linux linux 2.4.28 #2 =C3=B7=C3=94=C3=92 =C3=AE=C3=8F=C3=91 30 15:4=
3:35 MSK 2004 i686 unknown
> > gcc -v
> > Reading specs from /usr/lib/gcc-lib/i386-redhat-linux/2.96/specs
> > gcc version 2.96 20000731 (Red Hat Linux 7.3 2.96-113)
> > I have applies ebtables_brnf patch (http://bridge.sf.net) and a
>=20
> Don't do that then or contact the author to fix it. Unfortunately
> the code is also in 2.6 mainline.
>=20

Hi.

The bridge-nf code does not use recursive function calls and there is n=
o
long consecutive function calling. Furthermore, there is no function in
the bridge-nf code that uses a large part of the stack.
Andi, if you make such statements then please point out the code part
you have (of course) read after which you decided to make the statement=
=2E
The bridge-nf code is used by quite a few people and by commercial
companies and I have never had a report like this. AMD has been having
all sorts of strange problems for weeks now, they're all somehow relate=
d
to bridge-nf, but I doubt he is using the bridge-nf patch on a clean 2.=
4
kernel.
AMD, is there any chance you can use the latest 2.6 kernel, without
extra patches ?

Bart
