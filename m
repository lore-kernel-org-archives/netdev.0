From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Fri, 5 Nov 2004 12:54:31 +0100
Message-ID: <20041105115430.GP19714@rei.reeler.org>
References: <418B4C7C.8000402@crocom.com.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Szymon Miotk <spam@crocom.com.pl>
Content-Disposition: inline
In-Reply-To: <418B4C7C.8000402@crocom.com.pl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> [2.] Full description of the problem/report:
> I have a server with 3 links to ISPs and 1 link for internal network.
> I shape my clients to certain speeds, depending on the time of the day.
> I have HTB shaping on each interface, about 2250 classes and 2250 qdisc
> on each, so it makes total ~9000 classes (HTB) and ~9000 qdisc (SFQ).
> I run shaping scripts 4 times/day.

Could you send me the rules via private email or explain the
basic architecutre of it?

My first thought was that you might run out of stack space while
dumping the qdisc tree but it doesn't seem so regarding your
oops reports.

> Sometimes it makes a kernel oops, hangs at some 'tc ...' command (it
> differs).
> Then the shaping works so-so (usually it works, but doesn't fully
> utilize the bandwidth) and every iproute command hangs.
> Killing the hanging processes kills them, but still every iproute
> command hangs, including ip and tc.
> Sometimes the server stops forwarding, but usually it does so few hours
> after kernel oops.
> Reboot always helps.A

There have been at least 2 slab corruptions in CBQ and some
might have been ported over to HTB. I will look into it.

> Oct 31 15:02:38 cerber kernel:  [<c037325c>] tc_modify_qdisc+0x0/0x6e3
> Oct 31 15:02:38 cerber kernel:  [<c0373353>] tc_modify_qdisc+0xf7/0x6e3
> Oct 31 15:02:38 cerber kernel:  [<c01044e5>] error_code+0x2d/0x38
> Oct 31 15:02:38 cerber kernel:  [<c037325c>] tc_modify_qdisc+0x0/0x6e3

Something is wrong here and qdisc_lookup has something to do
with it. I will audit qdisc_list changes.

> my traffic shaping scripts are rather huge and they don't always cause
> kernel oops. I tried to run them together (so classes and qdisc on every
> interface were changed in parallel), but it didn't help.
> I can send you them if you wish.

My first guess is that something corrupts qdisc_list of the
device. I'm not sure what causes this but I will look into it
today.

> The default kernel has serious problems with traffic shaping, that was
> resolved in 2.6.9 kernel line.

Can you be more exact? Those were different issues, right?

> Without recompiling iproute, it hanged every time two iproute commands
> were run in parallel.

iproute2 problem or kernel problem? Can you give an example how
to trigger it?
