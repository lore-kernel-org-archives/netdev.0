From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] sb1000: prevent a potential NULL pointer dereference in sb1000_dev_ioctl()
Date: Sun, 29 Jul 2007 20:48:20 +0200
Message-ID: <200707292048.20531.mb@bu3sch.de>
References: <200707290002.42722.jesper.juhl@gmail.com> <alpine.LFD.0.999.0707291106500.30928@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0707300003440.30928@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Domen Puncer <domen@coderock.org>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Steven Hirsch <shirsch@adelphia.net>,
	"David S. Miller" <davem@davemloft.net>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:48916
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761718AbXG2Ssc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 14:48:32 -0400
In-Reply-To: <alpine.LFD.0.999.0707300003440.30928@enigma.security.iitk.ac.in>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 29 July 2007 20:34:46 Satyam Sharma wrote:
> (2) !(dev->flags & IFF_UP) is bogus because the functions of this ioctl
> can (and should) be allowed even when the interface is not up and running.

Are you _sure_? This function does poke with the device hardware.
It might return crap or even machinecheck when not initialized.
Hardware is probably powered down, if not IFF_UP. (I don't know if that's
the case here, though).

>  drivers/net/sb1000.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
> index 1de3eec..f60fe98 100644
> --- a/drivers/net/sb1000.c
> +++ b/drivers/net/sb1000.c
> @@ -993,9 +993,6 @@ static int sb1000_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  	unsigned int stats[5];
>  	struct sb1000_private *lp = netdev_priv(dev);
>  
> -	if (!(dev && dev->flags & IFF_UP))
> -		return -ENODEV;
> -


-- 
Greetings Michael.
