From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: possible rose recvmsg behavior change after msg_namelen fixes
Date: Fri, 20 Dec 2013 19:11:43 +0100
Message-ID: <20131220181143.GA10997@order.stressinduktion.org>
References: <20131220160207.GC29632@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>, linux-hams@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131220160207.GC29632@breakpoint.cc>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 20, 2013 at 05:02:07PM +0100, Florian Westphal wrote:
> Hi.
> 
> recvmsg handler in net/rose/af_rose.c performs size-check
> on  ->msg_namelen:
> 
> if (msg->msg_namelen >= sizeof(struct full_sockaddr_rose)) {
>  /* something */
> } else {
>   /* else */
> }
> 
> Now that msg_namelen is zeroed before the handler calls we always
> hit the 'else' branch.
> 
> TBH i don't comprehend how this was/is supposed to work.
> 
> Could someone who is familiar with AF_ROSE look at this, before
> I send untested patch that blindly chops off code?

Good catch, thanks!

If in doubt I would just replace msg->msg_namelen with sizeof(struct
sockaddr_storage) and do manual constant folding. ;)

I still have some patches in this area (somehow validating msg_namelen before
calling down to recvmsg, so that we don't dequeue a skb if the msg_name logic
would error out when writing the result back to user space).

The patch is still a mess but maybe we can pass the actual user-supplied
msg_namelen down then, eventually.

