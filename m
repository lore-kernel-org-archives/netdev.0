From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Wed, 6 Oct 2004 16:43:22 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041006214322.GG31237@waste.org>
References: <20041006232544.53615761@jack.colino.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Colin Leroy <colin@colino.net>
Content-Disposition: inline
In-Reply-To: <20041006232544.53615761@jack.colino.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 06, 2004 at 11:25:44PM +0200, Colin Leroy wrote:
> Hi,
> 
> this patch fixes a (quite big) problem with netpoll: when link is down,
> it hangs.
> 
> This patch fixes it. Tested with no carrier (no more hang) and with
> carrier (same behaviour as before).

[cc:ed to netdev]

Well this doesn't look unreasonable, but I haven't run into it with
the NICs I've tested. Nor have I seen this reported before. Which NICs
is this with?
 
> -	if(!np || !np->dev || !netif_running(np->dev)) {
> +	if(!np || !np->dev || !netif_running(np->dev) || 
> +	   !netif_carrier_ok(np->dev)) {

I wonder if netif_running is redundant if netif_carrier_ok.

-- 
Mathematics is the supreme nostalgia of our time.
