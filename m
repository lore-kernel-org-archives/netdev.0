From: Mikko Vinni <mmvinni@yahoo.com>
Subject: Re: br2684: convert to net_device_ops broke it
Date: Sat, 2 May 2009 13:02:40 -0700 (PDT)
Message-ID: <907051.51698.qm@web58405.mail.re3.yahoo.com>
References: <777914.38491.qm@web58405.mail.re3.yahoo.com> <20090502134605.GA11168@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Rabin Vincent <rabin@rab.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web58405.mail.re3.yahoo.com ([68.142.236.173]:30309 "HELO
	web58405.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759497AbZEBUCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 16:02:41 -0400
In-Reply-To: <20090502134605.GA11168@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Rabin Vincent wrote:

> On Sat, May 02, 2009 at 02:04:21AM -0700, Mikko Vinni wrote:
> > my ADSL connection works well with kernel 2.6.29, but since commit
> > 0ba25ff4c669e5395110ba6ab4958a97a9f96922 (br2684: convert to net_device_ops)
> > entered the mainline using br2684ctl fails with the following bug:
> [..]
> > I'll be glad to test any patches.
> 
> Please try the one below.

Yes, that fixes it. Good job and thank you!

Mikko


> 
> Rabin
> 
> From 9f767672d3362bb07fb1d8764b0d26312eb2bb96 Mon Sep 17 00:00:00 2001
> From: Rabin Vincent 
> Date: Sat, 2 May 2009 18:44:28 +0530
> Subject: [PATCH] br2684: restore net_dev initialization
> 
> Commit 0ba25ff4c669e5395110ba6ab4958a97a9f96922 ("br2684: convert to
> net_device_ops") inadvertently deleted the initialization of the net_dev
> pointer in the br2684_dev structure, leading to crashes.  This patch
> adds it back.
> 
> Reported-by: Mikko Vinni 
> Signed-off-by: Rabin Vincent 
> ---
> net/atm/br2684.c |    1 +
> 1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/atm/br2684.c b/net/atm/br2684.c
> index 334fcd4..3100a89 100644
> --- a/net/atm/br2684.c
> +++ b/net/atm/br2684.c
> @@ -549,6 +549,7 @@ static void br2684_setup(struct net_device *netdev)
>     struct br2684_dev *brdev = BRPRIV(netdev);
> 
>     ether_setup(netdev);
> +    brdev->net_dev = netdev;
> 
>     netdev->netdev_ops = &br2684_netdev_ops;
> 



      
