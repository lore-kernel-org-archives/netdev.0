From: P@draigBrady.com
Subject: gettimeofday scalability
Date: Tue, 05 Oct 2004 17:36:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4162CD76.4070204@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm starting to look again at the performance of my packet sniffer.
Any performace tips are appreciated (I'm using irq affinity and
CONFIG_PACKET_MMAP on 2.4.20 on a dual P4 xeon at present).

In particular I was wondering about reducing the overhead of
calling do_gettimeofday.

I noticed in the following paper that the xeon is much less
efficient than the P3 for gettimeofday (for the syscall at least):
http://www.labs.fujitsu.com/en/techinfo/linux/lse-0211/lse-0211.pdf

I've seen various gettimeofday locking speedup patches floating
around for 2.4. There is a version from Stephen and Andrea
that uses frlock, claiming 18%, and one from ingo that uses brlock.
2.6.8.1 uses seqlock, which contains the comment
that it's not as cache friendly as brlock.

So can anyone summarise the relative merits of these locking
mechanisms, before I start benchmarking?

thanks,
P=C3=A1draig.
