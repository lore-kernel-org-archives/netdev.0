From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: gettimeofday scalability
Date: Tue, 05 Oct 2004 11:48:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1097002080.22947.18.camel@localhost.localdomain>
References: <4162CD76.4070204@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, Ingo Molnar <mingo@elte.hu>,
        Andrea Arcangeli <andrea@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <4162CD76.4070204@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-10-05 at 17:36 +0100, P@draigBrady.com wrote:
> I'm starting to look again at the performance of my packet sniffer.
> Any performace tips are appreciated (I'm using irq affinity and
> CONFIG_PACKET_MMAP on 2.4.20 on a dual P4 xeon at present).
>=20
> In particular I was wondering about reducing the overhead of
> calling do_gettimeofday.
>=20
> I noticed in the following paper that the xeon is much less
> efficient than the P3 for gettimeofday (for the syscall at least):
> http://www.labs.fujitsu.com/en/techinfo/linux/lse-0211/lse-0211.pdf
>=20
> I've seen various gettimeofday locking speedup patches floating
> around for 2.4. There is a version from Stephen and Andrea
> that uses frlock, claiming 18%, and one from ingo that uses brlock.
> 2.6.8.1 uses seqlock, which contains the comment
> that it's not as cache friendly as brlock.

Don't bother with doing new work on 2.4. Look at 2.6.
You could use TSC in user space but you aren't going to see absolute
times and you run into all the portablity, and possible speed change
issues.

> So can anyone summarise the relative merits of these locking
> mechanisms, before I start benchmarking?
>=20
> thanks,
> P=E1draig.
