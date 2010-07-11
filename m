From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: Re: a couple questions about drivers/net/macv*.c
Date: Sat, 10 Jul 2010 22:31:39 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.1007102229570.2032@lynx>
References: <alpine.DEB.2.00.1007101652030.7658@lynx> <20100710.192610.232749731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:42242 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360Ab0GKCbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 22:31:49 -0400
In-Reply-To: <20100710.192610.232749731.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 10 Jul 2010, David Miller wrote:

> From: "Robert P. J. Day" <rpjday@crashcourse.ca>
> Date: Sat, 10 Jul 2010 19:44:59 -0400 (EDT)
>
> >
> >   first (trivial) point, i notice that both macvlan.c and macvtap.c
> > are still both listed as EXPERIMENTAL -- is that still accurate?
>
> Probably the tag should be removed, a lot of people use this
> facility and it works quite well as far as I can tell.
>
> >   bigger issue in macvtap.c -- notice this declaration:
> >
> > static unsigned int macvtap_major;
> >
> > that seems like a violation of coding style since that variable is
> > used later on in:
> >
> >         devt = MKDEV(MAJOR(macvtap_major), dev->ifindex);
> >  and
> >
> >        err = alloc_chrdev_region(&macvtap_major, 0,
> >                                 MACVTAP_NUM_DEVS, "macvtap");
> >
> > where its type should simply be the typedef "dev_t" for transparency,
> > should it not?
>
> Yep, I'll check in the following to net-next-2.6, thanks.
>
> --------------------
> macvtap: Use dev_t for macvtap_major.
>
> Reported-by: "Robert P. J. Day" <rpjday@crashcourse.ca>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/macvtap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index a8a94e2..2b4d59b 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -58,7 +58,7 @@ static struct proto macvtap_proto = {
>   * only has one tap, the interface numbers assure that the
>   * device nodes are unique.
>   */
> -static unsigned int macvtap_major;
> +static dev_t macvtap_major;

  technically, i would drop the "_major" suffix since that variable
doesn't represent simply the major device number but the entire dev_t
typedef, but that's your call.

rday

-- 

========================================================================
Robert P. J. Day                               Waterloo, Ontario, CANADA

        Top-notch, inexpensive online Linux/OSS/kernel courses
                        http://crashcourse.ca

Twitter:                                       http://twitter.com/rpjday
LinkedIn:                               http://ca.linkedin.com/in/rpjday
========================================================================
