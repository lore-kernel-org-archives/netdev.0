From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Connecting to sockets on MNT_READONLY mounts?
Date: Fri, 2 May 2014 00:51:35 +0100
Message-ID: <20140501235135.GE18016@ZenIV.linux.org.uk>
References: <CALCETrUXbS4BMWMd0XXgFqyvmpu+WML840_mzbPiov8WmaA=Xw@mail.gmail.com>
 <20140501223432.GD18016@ZenIV.linux.org.uk>
 <CALCETrXaXsVxaT3TH-CC8DKyDU7k=i9Y5PqBqaSDnH+2rr5E2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrXaXsVxaT3TH-CC8DKyDU7k=i9Y5PqBqaSDnH+2rr5E2A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 01, 2014 at 04:00:49PM -0700, Andy Lutomirski wrote:
> On Thu, May 1, 2014 at 3:34 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > On Thu, May 01, 2014 at 03:20:00PM -0700, Andy Lutomirski wrote:
> >> Is it supposed to work?
> >
> > Why the hell not?  Same as opening a device node on r/o filesystem for
> > write, or doing the same with FIFO.
> 
> You can't bind a socket on a read-only fs, so I thought it was a fair question.
> 
> I'll write a patch to add MS_NOIPCCONNECT and MNT_NOIPCCONNECT to
> block connect on unix sockets and open on fifos.  This will be useful
> for sandboxes that want to prevent sandboxed programs from accessing
> undesirable parts of the outside world.

Sigh...  Don't expose those FIFOs et.al. to them, then.
mount --bind /dev/null <pathname>
as part of setting the sucker up.  And if you *are* blindly exposing the
host filesystems to them wholesale, sockets and fifos are the least of your
problems, even if you do that read-only.
