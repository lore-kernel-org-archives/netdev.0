From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 13:42:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616204248.GA23617@bougret.hpl.hp.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@pobox.com, netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Gertjan van Wingerde <gwingerde@home.nl>
Content-Disposition: inline
In-Reply-To: <40D08769.3070106@home.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2004 at 07:46:17PM +0200, Gertjan van Wingerde wrote:
> 
> Scott,
> 
> I'm afraid that this isn't enough. I think we have to split up the various 
> settings over
> multiple commands. If we add just two commands (one for GET and one for 
> SET) we have to
> change the binary ioctl-interface every time a new setting arrives (e.g. 
> see how new
> settings will be added due to WPA support. That solution just isn't 
> future-proof.
> 
> Jean, Jouni, Jeff: What are your thoughts about this?

	You are asking me what I think about throwing away the API I
designed and restarting from scratch. You must be joking ;-)
	Furthermore, if you really want to redesign the API, then you
don't want to ask the guy responsible of the first one to avoid its
influence and avoid doing the same mistakes ;-)

	If you really want to have more background on my thoughts,
please look at this thread :
		http://marc.theaimsgroup.com/?t=107835339400003&r=1&w=2

	Seriously, these are my thoughts :
	o Backward/forward compatibility has always be my number one
priority since 1996. There is many wireless drivers *NOT* in the
kernel (see my web page) and many utilities using the current API. For
example, both the Red-Hat configurator and the Debian installer link
with libiw. So, it's not just about rewritting iwconfig.
	o Designing an API is not about choosing if you use multiple
ioctls or a single ioctl, or another mechanism. I don't care about
those details. Making choices will always make people unhappy.
	o I'm slow and lazy, but not opposed to changes, as long as
they are well motivated and designed. Yeah, for WPA, I totally suck,
but Jouni is going to save the day. I'm not opposed to fixing my
mistakes, as long as it's painless for people using the API.
	o If you really want to improve Linux-802.11 support, we
should focus first on the missing parts (in-kernel 802.11 framing and
management), not redo the stuff that already works.
	o I don't want to get in your way, so don't expect much from
me. If you can do a better job than me, then we all win.

	I also asked Jeff why he want to redesign the API, and in the
end there was only two issues :
	1) type-safe handler versus generic handler. I personally
disagree with Jeff on that one. But, you can easilly fix it by
offering wrapper to the current API :
	http://marc.theaimsgroup.com/?l=linux-netdev&m=107896289630224&w=2
	2) The use of ioctls. I've created a patch to add RtNetlink
support to the Wireless Extension API, and so far nobody has commented
on this :
	http://marc.theaimsgroup.com/?l=linux-netdev&m=107846135617655&w=2
	A more recent/functional version of this patch is on my web
page. I'm not going to waste time on this if nobody cares.

> I agree that we should be able to remove the commit 
> command if we are
> able to set multiple settings that belong together at the same time.

	Setting that belong together is highly dependant on how the
firware is written. With most cards, *all* setting belong together
(check the Raylink driver if you have time).
	The commit command in current WE is optional. You don't like
it, you don't use it.

	Are those the answer you were looking for, or did I miss
something ?

	Have fun...

	Jean
