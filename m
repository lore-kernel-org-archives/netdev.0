From: Colin Leroy <colin@colino.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Thu, 7 Oct 2004 07:53:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007075319.6b31430d@jack.colino.net>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20041006214322.GG31237@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 06 Oct 2004 at 16h10, Matt Mackall wrote:

Hi, 

> On Wed, Oct 06, 2004 at 11:25:44PM +0200, Colin Leroy wrote:
> > Hi,
> > 
> > this patch fixes a (quite big) problem with netpoll: when link is
> > down, it hangs.
> > 
> > This patch fixes it. Tested with no carrier (no more hang) and with
> > carrier (same behaviour as before).
> 
> [cc:ed to netdev]
> 
> Well this doesn't look unreasonable, but I haven't run into it with
> the NICs I've tested. Nor have I seen this reported before. Which NICs
> is this with?

Sungem. I didn't find anything strange in sungem, but it may be...
  
> > -	if(!np || !np->dev || !netif_running(np->dev)) {
> > +	if(!np || !np->dev || !netif_running(np->dev) || 
> > +	   !netif_carrier_ok(np->dev)) {
> 
> I wonder if netif_running is redundant if netif_carrier_ok.
 
Probably... I wanted to do the less modifications possible.

-- 
Colin
  http://colino.net/323/ - Presenting the Mazda 323 Rouge
