From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bugme-new] [Bug 1360] New: Can't access /proc/self/fd/0 from
 sshd when no pty allocated.
Date: Sat, 18 Oct 2003 23:57:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031018235735.52f5e15a.davem@redhat.com>
References: <200310151142.h9FBgi5k029003@fire-1.osdl.org>
	<20031018172736.417bf89d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dtucker@zip.com.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20031018172736.417bf89d.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 18 Oct 2003 17:27:36 -0700
Andrew Morton <akpm@osdl.org> wrote:

> This appears to be deliberate:
> 
> /*
>  *	In theory you can't get an open on this inode, but /proc provides
>  *	a back door. Remember to keep it shut otherwise you'll let the
>  *	creepy crawlies in.
>  */
>   
> static int sock_no_open(struct inode *irrelevant, struct file *dontcare)
> {
> 	return -ENXIO;
> }
> 
> I do not know why; the comment is fairly useless.

For many socket types there are no sane open() semantics.

If I open() a unconnected socket, what does that mean?
Should it connect, of do something like a dup()?

This code has been this way for a long time, anyone who wants to
change this needs to deal with and address all the aforementioned
issues.
