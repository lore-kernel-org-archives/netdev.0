From: Andi Kleen <ak@suse.de>
Subject: Re: do_IRQ: stack overflow: 872..
Date: 18 Dec 2004 08:50:49 +0100
Message-ID: <p73zn0ccaee.fsf@verdi.suse.de>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Crazy AMD K7 <snort2004@mail.ru>
In-Reply-To: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Crazy AMD K7 <snort2004@mail.ru> writes:

> Hi!
> I have found a few days ago strange messages in /var/log/messages
> More than 10 times there was do_IRQ: stack overflow: (nimber).... follo=
wed
> with code. If need I can send all this data. I have run
> ksymoops with only first 3 cases. Here is the first, the second and
> the third are in attachment.
> After that oopses my system continued to work.

It's not really an oops, just a warning that stack space got quiet tight.

The problem seems to be that the br netfilter code is nesting far too
deeply and recursing several times. Looks like a design bug to me,
it shouldn't do that.

> uname uname -a
> Linux linux 2.4.28 #2 =F7=D4=D2 =EE=CF=D1 30 15:43:35 MSK 2004 i686 unk=
nown
> gcc -v
> Reading specs from /usr/lib/gcc-lib/i386-redhat-linux/2.96/specs
> gcc version 2.96 20000731 (Red Hat Linux 7.3 2.96-113)
> I have applies ebtables_brnf patch (http://bridge.sf.net) and a

Don't do that then or contact the author to fix it. Unfortunately
the code is also in 2.6 mainline.

-Andi
