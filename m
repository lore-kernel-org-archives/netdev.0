From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] (2/4) packet scheduler bad TDIFF_SAFE in csz
Date: 29 Jun 2004 18:22:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088547756.1040.5.camel@jzny.localdomain>
References: <20040629140016.4afeb36b@dell_ss3.pdx.osdl.net>
	 <20040629144506.0649d217.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040629144506.0649d217.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


That scheduler is only a relic.
Nobody uses it ;-> Check the cofig help.
Pretty sure if you study it youll find a lot more bugs.

cheers,
jamal

On Tue, 2004-06-29 at 17:45, David S. Miller wrote:
> On Tue, 29 Jun 2004 14:00:16 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > This code in the csz scheduler, is just plain broken.  The TDIFF_SAFE 
> > effectively expands to:
> > 	unsigned long delay = now - q->t_c;
> > 	if (delay > 0) {
> > 		delay = 0;
> > 		goto do_reset;
> > 	}
> > 	if (delay >> q->delta_log)
> > 
> > So delay is always 0!  I assume that what was originally intended
> > is the to keep delay bounded to 1<<q->delta_log. 
> 
> This bug has been there since day one, wow.
> 
> Good spotting, applied.
> 
> 
