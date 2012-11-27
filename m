From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH RFC 3/5] printk: modify printk interface for
	syslog_namespace
Date: Tue, 27 Nov 2012 07:58:38 -0600
Message-ID: <20121127135838.GB4127@sergelap>
References: <50B0ADDB.4000303@gmail.com>
	<20121125042802.GB4523@mail.hallyn.com>
	<50B4BF64.6010707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Libo Chen <chenlibo.3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50B4BF64.6010707-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Quoting Libo Chen (chenlibo.3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> 
> On 2012-11-25 12:28, Serge E. Hallyn wrote:
> > Quoting Libo Chen (chenlibo.3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> >> On 2012/11/22 1:49, Serge E. Hallyn wrote:
> >>
> >>> I notice that you haven't made any changes to the struct cont.  I
> >>> suspect this means that to-be-continued msgs from one ns can be
> >>> erroneously mixed with another ns.
> >>>
> >> Yes, I confirmed this problem. There will be erroneously mixed with another ns.
> >> Thank you very much.
> >>
> >>> You said you don't mind putting the syslogns into the userns.  If
> >>> there's no reason not to do that, then we should do so as it will
> >>> remove a bunch of code (plus the use of a new CLONE flag) from your
> >>> patch, and the new syslog(NEW_NS) command from mine.
> >>>
> >> I agree with you, both are removable.
> >>
> >>> Now IMO the ideal place for syslog_ns would be in the devices ns,
> >>> but that does not yet exist, and may never.  The bonus to that would
> >>> be that the consoles sort of belong there.  I avoid this by not
> >>> having consoles in child syslog namespaces.  You put the console in
> >>> the ns.  I haven't looked closely enough to see if what you do is
> >>> ok (will do so soon).
> >>>
> >>> WOuld you mind looking through my patch to see if it suffices for
> >>> your needs?  Where it does not, patches would be greatly appreciated
> >>> if simple enough.
> >>
> >> follow your patch, I can see inject message by "dmesg call" in container, is right?
> > 
> > If I understand you right, yes.
> > 
> >> I am worry that I debug  or see messages from serial ports console in some embedded system,
> >> since console belongs to init_syslog,  so the message in container can`t be printed. 
> > 
> > Sorry, I don't understand which way you're going with that.  Could you
> > rephrase?  You want to prevent console messages from going to a
> > container?  (That should definately not happen)  Or something else?
> > 
> 
> I reviewed your patch, and found that console could only print messages
> belonging to init_syslog.
> 
> So the message belongs to container syslog can not be printed from console,
> but only "dmesg call" in user space.  Is that right?
> 
> For example, the messages can not be outputed automatically from serial port
> as a kind of consoles on some embedded system.

Oh, I see.  I basically thought this was a feature, not a problem :)  But
that wasn't meant to be a core part of my patchset, rather I wasn't quite
sure how best to handle it, so I put it off for later.  My main concern is
that if consoles in containers are supported, this must NOT lead to
kernel module loading from the container.

> And I am not sure if there are no other problems.

Ok, I will write a new patch which would (a) try to address the consoles,
(b) move the syslogns into the user_ns (making it no longer a syslog_ns),
and (c) adding some users of ns_printk (borrowing the ones from your
set for starters).

thanks,
-serge
