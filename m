From: Darren Tucker <dtucker@zip.com.au>
Subject: Re: [Bugme-new] [Bug 1360] New: Can't access /proc/self/fd/0 from sshd
 when no pty allocated.
Date: Wed, 22 Oct 2003 18:40:51 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F964293.FA2C3A7A@zip.com.au>
References: <200310151142.h9FBgi5k029003@fire-1.osdl.org>
 <20031018172736.417bf89d.akpm@osdl.org>
 <20031018235735.52f5e15a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
> On Sat, 18 Oct 2003 17:27:36 -0700
> Andrew Morton <akpm@osdl.org> wrote:
> 
> > This appears to be deliberate:
[snip]
> >
> > I do not know why; the comment is fairly useless.
> 
> For many socket types there are no sane open() semantics.
> 
> If I open() a unconnected socket, what does that mean?
> Should it connect, of do something like a dup()?
> 
> This code has been this way for a long time, anyone who wants to
> change this needs to deal with and address all the aforementioned
> issues.

Thanks for looking at this.

I've done some digging on the OpenSSH side: originally sshd used pipes on
Linux but they were found [0] to have problems that cause lockups in (at
least) rsync.

[0] http://marc.theaimsgroup.com/?l=openssh-unix-dev&m=94914935131492

-- 
Darren Tucker (dtucker at zip.com.au)
GPG key 8FF4FA69 / D9A3 86E9 7EEE AF4B B2D4  37C9 C982 80C7 8FF4 FA69
    Good judgement comes with experience. Unfortunately, the experience
usually comes from bad judgement.
