From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] bonding: enhance the IP address check of arp_ip_target
Date: Tue, 11 Jul 2006 21:53:17 -0700
Message-ID: <20060711215317.7d673f89@localhost.localdomain>
References: <44B479D0.5080204@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	takatatt@intellilink.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13464 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932151AbWGLExc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 00:53:32 -0400
To: Tetsuo Takata <takata.tetsuo@oss.ntt.co.jp>
In-Reply-To: <44B479D0.5080204@oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Jul 2006 13:25:52 +0900
Tetsuo Takata <takata.tetsuo@oss.ntt.co.jp> wrote:

> Hi,
> 
> 
> I found this in drivers/net/bonding/bond_main.c.
> > /* not complete check, but should be good enough to
> >     catch mistakes */
> 
> I made a patch which I believe is little bit better than this,
> I hope...
> 
> 
> best regards,
> 
> ---
> Signed-off-by: Tetsuo Takata <takatatt@intellilink.co.jp>
> 
> --- linux-2.6.17.3/drivers/net/bonding/bond_main.c	2006-07-01 02:37:38.000000000 +0900
> +++ linux-2.6.17.3-bonding-ipcheck/drivers/net/bonding/bond_main.c	2006-07-12 09:51:12.000000000 +0900
> @@ -4455,7 +4455,113 @@ static int bond_check_params(struct bond
>  	     arp_ip_count++) {
>  		/* not complete check, but should be good enough to
>  		   catch mistakes */
> -		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
> +		int i, notip = 0;
> +		char *cp;
> +
> +		cp = arp_ip_target[arp_ip_count];
> +
> +		/* notip's number is the error code for debug purpose */
> +		do {
> +			if (cp == NULL) {
> +				notip = 1;
> +				break;
> +			}
> +
> +			/* check digit */
> +			for (i = 0; isdigit(*cp); i++) {
> +				if ((i < 0) || (i >= 3)) {
> +					notip = 2;
> +					break;
> +				}
> +				cp++;
> +			}
> +			if (notip)
> +				break;
> +
> +			if (i == 0) {
> +				notip = 3;
> +				break;
> +			}
> +
> +			/* check delimiter */
> +			if (*cp != '.') {
> +				notip = 4;
> +				break;
> +			}
> +			cp++;
> +
> +			/* check digit */
> +			for (i = 0; isdigit(*cp); i++) {
> +				if ((i < 0) || (i >= 3)) {
> +					notip = 5;
> +					break;
> +				}
> +				cp++;
> +			}
> +			if (notip)
> +				break;
> +
> +			if (i == 0) {
> +				notip = 6;
> +				break;
> +			}
> +
> +			/* check delimiter */
> +			if (*cp != '.') {
> +				notip = 7;
> +				break;
> +			}
> +			cp++;
> +
> +			/* check digit */
> +			for (i = 0; isdigit(*cp); i++) {
> +				if ((i < 0) || (i >= 3)) {
> +					notip = 8;
> +					break;
> +				}
> +				cp++;
> +			}
> +			if (notip)
> +				break;
> +
> +			if (i == 0) {
> +				notip = 9;
> +				break;
> +			}
> +
> +			/* check delimiter */
> +			if (*cp != '.') {
> +				notip = 10;
> +				break;
> +			}
> +			cp++;
> +
> +			/* check digit */
> +			for (i = 0; isdigit(*cp); i++) {
> +				if ((i < 0) || (i >= 3)) {
> +					notip = 11;
> +					break;
> +				}
> +				cp++;
> +			}
> +			if (notip)
> +				break;
> +
> +			if (i == 0) {
> +				notip = 12;
> +				break;
> +			}
> +
> +
> +			/* check EOS */
> +			if (*cp != '\0') {
> +				notip = 13;
> +				break;
> +			}
> +
> +		} while(0);
> +
> +		if (notip) {
>  			printk(KERN_WARNING DRV_NAME
>  			       ": Warning: bad arp_ip_target module parameter "
>  			       "(%s), ARP monitoring will not be performed\n",
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Why not just use sscanf?

-- 
If one would give me six lines written by the hand of the most honest
man, I would find something in them to have him hanged. -- Cardinal Richlieu
