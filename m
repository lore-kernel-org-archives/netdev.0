From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: iproute2 and kernel headers
Date: Fri, 6 Aug 2004 17:07:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040807000707.GB11761@bougret.hpl.hp.com>
References: <20040805005019.GA11538@bougret.hpl.hp.com> <20040806093920.045b379e@dell_ss3.pdx.osdl.net>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040806093920.045b379e@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 06, 2004 at 09:39:20AM -0700, Stephen Hemminger wrote:
> On Wed, 4 Aug 2004 17:50:19 -0700
> Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:
> > 
> > 	Now, my sick brain would like to suggest a few other crazy
> > solutions totally out of the box :
> > 
> > 	1) Get it right the first time, so no change is ever
> > needed. If things are standardised (POSIX, IEEE), this can work, if
> > you are called Linus, most likely, otherwise, good luck...
> 
> The management API's are what seemed to get changed the most.
> The only relevant standard's seem to be SNMP, but it doesn't match
> the kernel API needs.

	And SNMP standardisation usually is late to the party.

> > 	2) Migrate all those kernel APIs to XML. XML is the future,
> > you can validate the output, and you can add/remove nodes/attributes
> > between versions without the full thing falling apart. And we already
> > have a web server in the kernel.
> 
> No, don't reinvent SOAP for kernel API's.

	I feel honored that you are taking my braindamage so
seriously. Maybe I should have suggested to have a Lisp command line
to configure the kernel (angle brackets or parenthesis, all the same
to me).
	The beauty of XML is that you can use any gramar you want and
still be compliant. Obviously, we have to define our own gramar, named
LKXML :
	<Linus>
		<Proc>i386</Proc>
		<JeffG>
			<eth0 full_duplex="on"/>
		</JeffG>
		<DaveM>
			<TCPVegas Alpha="2" Beta="6"/>
		</DaveM>
		<RMK>
			<arch>StrongARM</arch>
		</RMK>
		<StephenH>
			<Bug Text="Incompatible statements" Severity="42">
				<Proc>i386</Proc>
				<arch>StrongARM</arch>
			</Bug>
		</StephenH>
	</Linus>

> > 	3) Every time you need to change the API, migrate it to
> > another delivery mechanism and create a totally different set of
> > tools. If you were using ioctl, migrate to netlink. If you were using
> > netlink, migrate to a pseudo filesystem. Obviously the holy grail is
> > to make it a system call. Also, make sure to kill the old APIs and old
> > tools, otherwise some other folks my continue to maintain it.
> 
> Doesn't make sense unless the new interface is better.
> Just use different ioctl's or message types.

	Hum... Every time I will change the data struct (add a field,
change a field type), I will move to a new ioctl number. Maybe we want
to migrate ioctl numbers from 32 bits to 64 bits to avoid quickly
exhausting the ioctl space.

> > 	4) Distribute all those system utilities as part of the
> > kernel, compile them as part of the kernel, and install them in a
> > kernel specific directory. Basically, treat system utilities exactly
> > the same way as kernel modules.
> > 	That actually would go a long way toward solving the issue of
> > distribution of system utils (where is module-init-tools ?) and push
> > more people to implement their pet project in user space rather than
> > in the kernel.
> 
> Too old school, unix.  It might have worked in the past, and we might
> end up back there, but it ain't going to happen now.

	I pretty much test every kernel release, and every month I
need to go in /lib/modules and remove obsolete modules directories to
free some disk space. The idea of having a new version of
ifconfig/iwconfig/iproute/cardmgr/... on my hard disk every time I
upgrade my kernel doesn't appeal to me.
	Note : this is why I kill the wireless redirector stuff.

> > 	I wish you a lot of luck exploring those issues, and if one of
> > those long nights you have a Eureka moment, please share with us ;-)
> > 	Have fun...
> 
> You ignored the advantage of using simple string interfaces (a.l.a Plan 9)
> or simple name:value pairs.

	Yep, you can do everything with strings, even introduces
parsing bugs in the kernel (been there...). It's also fun dealing with
fields that contain spaces or fancy character in them, fortunately it
only happen when the API is specified by non-Unix standards. And there
is so many formating of simple name:value pairs (with ':', '=' or ' '
as separator). By the way, as far as I am concerned, XML is just a
fancy name:value pairs format with angle brackets (see above).
	Also, it depends if you care about kernel bloat. Maybe we
should make kernel memory swapable.

	Note : I have some kernel APIs that are ASCII based. It's
worth it because you don't need user tools at all. But unfortunately
it's not always applicable, otherwise stuff like RtNetlink that don't
require backward compatibility would have been designed ASCII based.

> Also, it turns out that some simple things like
> increasing the size of the structure or adding a new rtnetlink message type
> are not too hard to deal with.

	Actually, reading a struct that increased in size will make
your read buffer overflow if you are not careful. Note that this is
the solution I adopted in the end, but as I say, you need to be
careful.
	Note that with respect to your *original* problem (yeah, we
are so slightly off-topic), if this is the case you only need to
include the very latest version of the header, and don't really care
what is the actual header in the kernel.

	Have fun...

	Jean
