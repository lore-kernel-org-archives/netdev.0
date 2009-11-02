From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder Cookie
Date: Mon, 02 Nov 2009 14:16:44 +0100
Message-ID: <4AEEDBBC.40800@gmail.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com> <4AEEB6D2.7090505@gmail.com> <4AEEBAC6.7020308@gmail.com> <4AEED23A.7070009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755145AbZKBNQn@vger.kernel.org>
In-Reply-To: <4AEED23A.7070009@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson a =E9crit :
> Eric Dumazet wrote:
>> cookie_hash() runs in a non preemptable context. CPU cannot change
>> under us.
>>
>> (or else, we would not use __get_cpu_var(ipv4_cookie_scratch); )
>>
>> And of course, each cpu gets its own scratch area, thanks to
>> __get_cpu_var()
>>
> Interesting.  I'm not sure that running CPU intensive functions like
> SHA1 in
> a non-preemptable context is a good idea.  I'd assumed it wasn't!
>=20
> Perhaps you could point at the documentation in the code that explain=
s
> this?

I suggest you read Documentations/ files about softirq

http://docs.blackfin.uclinux.org/kernel/generated/kernel-hacking.xml


Large part of network code is run by softirq handler, and a softirq han=
dler
is not preemptable with another softirq (including itself).


> Perhaps a function header comment that mentions it?

So we are going to add a header to thousand of functions repeating this=
 prereq ?

>=20
> All I know is (from testing) that the tcp_minisockets.c caller is som=
etimes
> called in a fashion that requires atomic allocation, and other times
> does not!

Maybe callers have different contexts (running from softirq handler or
from process context). Atomic ops are expensive and we try to avoid the=
m
if/when possible.

>=20
> See my "Subject: query: tcpdump versus atomic?" thread from Oct 14th.

You probably add a bug in your kernel, leaving a function with unpaired=
 lock/unlock
of notallow_something/allow_something

There are books about linux internals that you could read if you want s=
ome extra
documentation. Dont ask me details, I never read them :)
