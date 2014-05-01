From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Connecting to sockets on MNT_READONLY mounts?
Date: Thu, 1 May 2014 16:00:49 -0700
Message-ID: <CALCETrXaXsVxaT3TH-CC8DKyDU7k=i9Y5PqBqaSDnH+2rr5E2A@mail.gmail.com>
References: <CALCETrUXbS4BMWMd0XXgFqyvmpu+WML840_mzbPiov8WmaA=Xw@mail.gmail.com>
 <20140501223432.GD18016@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140501223432.GD18016@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 1, 2014 at 3:34 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Thu, May 01, 2014 at 03:20:00PM -0700, Andy Lutomirski wrote:
>> Is it supposed to work?
>
> Why the hell not?  Same as opening a device node on r/o filesystem for
> write, or doing the same with FIFO.

You can't bind a socket on a read-only fs, so I thought it was a fair question.

I'll write a patch to add MS_NOIPCCONNECT and MNT_NOIPCCONNECT to
block connect on unix sockets and open on fifos.  This will be useful
for sandboxes that want to prevent sandboxed programs from accessing
undesirable parts of the outside world.

--Andy
