From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Sun, 02 Oct 2011 11:06:25 -0400
Message-ID: <6.2.5.6.2.20111002110545.03a82460@binnacle.cx>
References: <6.2.5.6.2.20111001215241.03a7ed48@binnacle.cx>
 <1317540066.3802.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317540066.3802.32.camel@edumazet-laptop>
References: <6.2.5.6.2.20111001215241.03a7ed48@binnacle.cx>
 <1317540066.3802.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 09:21 AM 10/2/2011 +0200, Eric Dumazet wrote:
>Le dimanche 02 octobre 2011 =C3  01:33 -0400,=20
>
>You might try to disable any fancy power saving
>mode in your machine.  Maybe on your machine, cost
>to enter/exit deep sleep state is too high.

I'll check this out.  It's an Opteron 6174 and
so recent and with all the aggressive power
saving AMD can dish out.  Note that 'cpuspeed'
is turned off.  Only thing I can think of
off the top of my head is to boot with=20
'nohalt' (which used to be idle=3Dpoll).  If
anyone knows further Magney Cours tweaks
please let me know.

>Just to clarify a bit :
>
>Sometimes, optimizing one part of the kernel can
>have a negative impact on some workloads because
>we end up doing more sleep/wakeup of consumers :
>Several threads might try to acquire a lock at the
>same time, while previously they got no
>contention.
>
>In 2.6.35, commit c377411f2494a (net:
>sk_add_backlog() take rmem_alloc into account)
>changed backlog limit, avoid taking socket lock on
>flood, allowing to receive 200.000 pps on a test
>machine instead of 100pps.  But the receiver was
>doing a plain
>
>while (1)
>	recv(...);
>
>And maximum throughput was reached because task
>never called scheduler...

Sometimes I think it might be nice to run without
an OS at all :-)

We are looking at various kernel bypass approaches
for receiving packets and it's in my mind that
one of these may get us to running on newer
kernels without giving up performance.

>I see nothing obvious in the profile but userland
>processing, futex calls.

Indeed, this is from the app-internal queuing
I mentioned in the last post.  Because UDP is
presently unusable in any .32 or .39 kernel
I'm stuck with using packet sockets as a proxy
for them.  As mentioned, the two produce very
similar results in all past tests.

>Network processing seems to account less than 10%
>of total cpu...  All this sounds more a process
>scheduling regression than a network stack one..

Interesting.  When I start testing kernel bypass
the degree to which this is the case should become
clear.

>On new kernels, you can check if your udp sockets
>drops frames because of rcvbuffer being full (cat
>/proc/net/udp, check last column 'drops')

As I've stated several times, all these tests are
run with verifiable zero data loss.  The max-load
test is the highest rate were zero data loss can
be maintained.  UDP socket buffers are set to 64MB.

>To check if softirq processing hit some limits :
>cat /proc/net/softnet_stat

Ok.

>Please send full "dmesg" output=20

Ok.

At 07:47 AM 10/2/2011 -0700, Stephen Hemminger wrote:
>Try disabling PCI DMA remapping. The additional
>overhead of setting up IO mapping can be a
>performance buzz kill. Try CONGIG_DMAR=3Dn

Definitely.  Thanks for the tip!

-----

Probably won't get to these until Monday or
Tuesday.
