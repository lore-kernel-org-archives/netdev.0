From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: mtu_expires variable
Date: Sun, 18 May 2003 17:40:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030518174024.014cb734.rddunlap@osdl.org>
References: <Pine.GSO.4.10.10305162243050.13822-100000@tigre.dcc.unicamp.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe Massia Pereira <massia@ic.unicamp.br>
In-Reply-To: <Pine.GSO.4.10.10305162243050.13822-100000@tigre.dcc.unicamp.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 16 May 2003 23:16:03 -0300 (EST) Felipe Massia Pereira <massia@ic.unicamp.br> wrote:   [on LKML]

| Hello,
| 
| I've been searching for the exact meaning of this variable through
| Documentation and I've found just empty descriptions (to be filled in, in
| Advanced Linux Routing HOWTO, and nothing also in
| Documentation/networking/ip-sysctl.txt). I've tried also to read the
| kernel source code (net/ipv4/route.c) but I could not figure out what they
| mean.

What kernel version?
And this question would be better asked/answered on either
linux-net or netdev mailing lists, so I've replied to those.

It (ip_rt_mtu_expires variable) appears not to be used very much.

| I've came accross this var because we want to do some experiments in class
| with Path MTU discovery.  But it happens that MTU is recorded between
| experiments (and it's what we expect: that the stack does not do a PMTU
| every time). BTW where is the PMTU value kept? Is MTU value recorded for
| each destination or for each route?
| 
| So it would be nice if we could make the value found in a experiment to be
| forgotten by the kernel so the students could execute the ping several
| times. (ping -c 2 -m want ...) Is mtu_expires what we're looking for?

Maybe someone else can answer this...

| We tried to "echo 1 > /proc/sys/net/ipv4/route/mtu_expires" considering
| that it's expressed in seconds. The usual value is 600. But I've read that
| it's expressed in jiffies. Jiffies occur 100 times per sec on a PC, is it?
| So the value 600 on a PC means 6 seconds?

In 2.4.x there are 100 jiffies / second on a PC (x86 arch).
However, /proc/sys/net/ipv4/route/mtu_expires is hiding this HZ
conversion factor from us, so that the value is expressed in seconds
and not in jiffies, so 600 is 600 seconds = 10 minutes.

--
~Randy
