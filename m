From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: Re: [PATCH] net: rose: Use mod_timer
Date: Sat, 6 Jun 2015 10:02:30 +0200
Message-ID: <20150606080230.GB16240@linux-mips.org>
References: <20150606042234.GA15542@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>
To: Vaishali Thakkar <vthakkar1994@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150606042234.GA15542@vaishali-Ideapad-Z570>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vaishali,

On Sat, Jun 06, 2015 at 09:52:34AM +0530, Vaishali Thakkar wrote:

> Use mod_timer instead of del_timer followed by add_timer to update
> the expire field of the active timer.
> 
> The semantic patch that performs this transformation is as follows:
> 
> @change@
> expression e1, e2, e3, e4;
> @@
> 
> - del_timer(&e1);
> ... when != e1 = e3
> - e1.expires = e2;
> ... when != e1 = e4
> - add_timer (&e1);
> + mod_timer (&e1, e2);

This isn't quite right.  All the instances of this pattern in the ROSE
stack also modify the timer's data and function fields which if the timer
is still running and expiring while being fiddled with, might result in
a race condition, that is the old function but new data field being used
in combination or something like that.

For some of the timers (maybe all?) it should be possible to proof that
always the same values for data and function are being used.  These
initializations could then be used elsewhere and the code could then
indeed be switched to mod_timer.

  Ralf
