From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] 2.6 UDP recvmsg vs POSIX
Date: Mon, 23 Feb 2004 09:42:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223094216.66602afd.davem@redhat.com>
References: <20040217121726.GD8554@suse.de>
	<20040221130853.4c98bad6.davem@redhat.com>
	<20040223094209.GA12663@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040223094209.GA12663@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 Feb 2004 10:42:10 +0100
Olaf Kirch <okir@suse.de> wrote:

> But that breaks poll/recvmsg on a blocking socket, because poll with
> assert POLLIN, but the recvmsg call with block.

There is nothing wrong with that, I even pinged Linus about this and he
agreed with me.

What stops another thread from pulling a packet from the
receive queue and thus emptying it?  Nothing.  POLLIN does not guarentee
a read will give you data right now, it never has and it never will.

Therefore, the only bug was returning -EAGAIN unconditionally and that's
what is fixed by the correct half of your changes.

TCP does the same thing Olaf, and there is no way I'm adding the gross poll
hacks there :-)
