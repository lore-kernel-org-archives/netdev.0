From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1/7] netpoll: shorten carrier detect timeout
Date: Thu, 10 Mar 2005 15:01:17 -0800
Message-ID: <20050310230117.GP3120@waste.org>
References: <2.454130102@selenic.com> <422A4A38.4040303@trash.net> <20050306002015.GD3120@waste.org> <422A564D.4080809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Jeff Moyer <jmoyer@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <422A564D.4080809@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 06, 2005 at 02:01:01AM +0100, Patrick McHardy wrote:
> Matt Mackall wrote:
> >On Sun, Mar 06, 2005 at 01:09:28AM +0100, Patrick McHardy wrote:
> >>
> >>The carrier detection looks partially broken to me. The current logic
> >>detects an instantly available carrier as flaky because
> >>netif_carrier_ok() takes less than 1/10s. This patch does what
> >>I assume is intended, make sure the carrier is stable for 1/10s.

Ok, on closer inspection, the current logic is: the NIC reports
carrier detect nearly instaneously and thus its carrier detect
reporting is considered unreliable. Rather than immediately sending
packets, we wait for some interval for it to really be up so that the
backlog of console messages doesn't get pumped into the bit bucket.

So I'm going to change it from "flaky" to "untrustworthy" and add a
comment.

> How about this one ? I also removed oflags, reading it outside of
> the locked section was racy.

I'll do this as a separate patch.

> >Did you try this with a card that otherwise goes into the wait?
> 
> Yes, I tried with sk98lin. I don't have a card here that actually
> supports netpoll.

Huh? sk98lin appears to support it?

-- 
Mathematics is the supreme nostalgia of our time.
