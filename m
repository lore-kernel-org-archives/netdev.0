From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] unclamp tcp receive window if doing dynamic receive
 sizing
Date: Mon, 7 Jun 2004 16:17:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607161741.1f295aca.davem@redhat.com>
References: <20040607133056.5ab9e72d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040607133056.5ab9e72d@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Jun 2004 13:30:56 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> When running tests over higher speed links, the new 2.6 Dynamic Receiver Sizing
> code doesn't increase the window large enough.  The problem is that the window
> clamp restricts the allowed window to the socket receive buffer size (85k)
> 
> Easiest fix is to not restrict window clamp if we want to dynamic receiver stuff.
> This is what web100 did.
> 
> Thanks to John Heffner for finding this.

This turns off all tcp_app_win semantics, are you sure that
tcp_app_win makes no sense when doing dynamic receive buffer
sizing?  I think we should still factor it in, perhaps dynamically,
during rcvbuf growth.
