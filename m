From: Lennert Buytenhek <buytenh@gnu.org>
Subject: Re: [PATCH,RFC] explicit connection confirmation
Date: Thu, 7 Nov 2002 09:30:02 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021107143002.GA23858@gnu.org>
References: <20021107093207.GA30666@gnu.org> <20021107112733.GA24283@outpost.ds9a.nl> <20021107120956.GA10832@gnu.org> <20021107134918.GA28329@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20021107134918.GA28329@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Thu, Nov 07, 2002 at 02:49:18PM +0100, bert hubert wrote:

> > > I think this approach smells, btw - doesn't this mean that processes
> > > will now be woken up on receiving a SYN instead of after completion
> > > of the handshake?
> > 
> > Yes, it does mean this.  You are free to suggest alternatives.
> 
> I like having this ability - I dislike offering it to an unsuspecting
> userspace.

Userspace needs to turn on the option first, so your 'unsuspecting'
does not apply.


> > > Would make a synflood all the more interesting..
> > 
> > In case of a synflood, the TCP stack will fall back to sending
> > syncookies as it normally does.
> 
> Yes, but in your setup, a spoofable SYN packet will spawn a process for many
> daemons, unless they are modified to first try to read/write to the socket
> (which might block!) before forking/pthread_create()ing.

Again, if the app decides to turn on TCP_CONFIRM_CONNECT, then it's
up to the app to deal with it properly.  There are very good reasons
for not turning on TCP_CONFIRM_CONNECT by default, which is why it
is not on by default, and why grafting a setsockopt onto every daemon
there is out there is definitely not a good idea.


cheers,
Lennert
