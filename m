From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (2/4) packet scheduler bad TDIFF_SAFE in csz
Date: Tue, 29 Jun 2004 14:45:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629144506.0649d217.davem@redhat.com>
References: <20040629140016.4afeb36b@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040629140016.4afeb36b@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Jun 2004 14:00:16 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This code in the csz scheduler, is just plain broken.  The TDIFF_SAFE 
> effectively expands to:
> 	unsigned long delay = now - q->t_c;
> 	if (delay > 0) {
> 		delay = 0;
> 		goto do_reset;
> 	}
> 	if (delay >> q->delta_log)
> 
> So delay is always 0!  I assume that what was originally intended
> is the to keep delay bounded to 1<<q->delta_log. 

This bug has been there since day one, wow.

Good spotting, applied.
