From: "David S. Miller" <davem@redhat.com>
Subject: Re: synchronize_net()?
Date: Sat, 13 Sep 2003 19:09:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030913190940.4aaf5817.davem@redhat.com>
References: <20030913034611.GA83212@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20030913034611.GA83212@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2003 20:46:11 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> /* Synchronize with packet receive processing. */
> void synchronize_net(void) 
> {
>         might_sleep();
>         synchronize_kernel();
> }
> 
> The "might_sleep()" isn't needed

As a matter of taste and ease of debugging it could be.

I think it's logical to place the might_sleep() calls as high
up in the call chain as is reasonable.  This is especially true
for important oft-used interfaces for a subsystem.

In this way, you don't risk so much having a hard to decode backtrace
that misses the true culprit sleep'able call.
