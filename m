From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: how to set pppoe source mac address?
Date: Sun, 21 Oct 2007 21:05:15 +0200
Message-ID: <007901c81415$50898e40$5267a8c0@Jocke>
References: <471B9181.8010502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Patrick McHardy'" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:32789 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751440AbXJUTFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 15:05:22 -0400
In-Reply-To: <471B9181.8010502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Patrick McHardy [mailto:kaber@trash.net] 
> Sent: den 21 oktober 2007 19:51
> To: Joakim Tjernlund
> Cc: netdev@vger.kernel.org
> Subject: Re: how to set pppoe source mac address?
> 
> Joakim Tjernlund wrote:
> > I have several pppoe i/f's over one eth i/f and I want to set the
> > source mac address used by each pppoe i/f to a unique mac 
> address from
> > user space.
> > 
> > Is this possible? If so, how do I do that?
> 
> 
> Try the macvlan driver.
> 

Thanks, but I can't see that it will help.

I am looking for something like this that I currently have added
to pppoe_ioctl() in pppoe.c: 
 
 case PPPOEIOCSSRCMAC:
        {
            struct relay_source_mac smac;

            err = -EBUSY;
            if (sk->sk_state & (PPPOX_BOUND|PPPOX_ZOMBIE|PPPOX_DEAD))
                break;

            err = -ENOTCONN;
            if (!(sk->sk_state & PPPOX_CONNECTED))
                break;

            err = -EFAULT;
            if (copy_from_user(&smac, (void *) arg, sizeof(smac)))
                break;

            memcpy(po->srcmac, smac.srcmac, ETH_ALEN);

            err = 0;
            break;
        }

then changed the call to hard_header in __pppoe_xmit() to
     dev->hard_header(skb, dev, ETH_P_PPP_SES,
                      po->pppoe_pa.remote,
                      po->srcmac, data_len);

Would a new ioctl(PPPOEIOCSSRCMAC) to pppoe be acceptable?

 Jocke

