From: Michael Brade <brade@informatik.uni-muenchen.de>
Subject: Re: r8169 hard-freezes the system on big network loads
Date: Sun, 11 Sep 2011 22:16:33 +0200
Message-ID: <201109112216.33579.brade@informatik.uni-muenchen.de>
References: <201108141308.28140.kjun-chen@sambodha.org> <20110821221140.GA20696@electric-eye.fr.zoreil.com> <20110823131726.GA21092@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acheron.ifi.lmu.de ([129.187.214.135]:52376 "EHLO
	acheron.ifi.lmu.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281Ab1IKUQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2011 16:16:58 -0400
In-Reply-To: <20110823131726.GA21092@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 August 2011 15:17:26 Francois Romieu wrote:
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
> 
> > Yes. There is enough data for me to reproduce the bug with the
> > exact same chipset.
> 
> I can not generate a single rx error and the driver refuses to crash :o/
> 
> Can you apply the patch below on top of 3.1.0-rc3 and see if it makes
> a difference ?

Sorry for the delay, I have had only two days for email in the last few weeks 
and additionally kernel.org was and still is down.

Does it have to be 3.1.0-rc3 or is 3.0.1 ok as well? If so, I have another bad 
news: 3.0.1 still crashes with this patch. It took me a lot longer to crash it 
but eventually it did happen. Not sure why it took longer, I guess I didn't 
generate enough throughput.

If you want me to use 3.1.0 then we'll have to wait until git.kernel.org is 
back...

thanks,
  Michael


 
> Thanks.
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 02339b3..c54ed17 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -5326,10 +5326,6 @@ static int rtl8169_rx_interrupt(struct net_device
> *dev, dev->stats.rx_length_errors++;
>  			if (status & RxCRC)
>  				dev->stats.rx_crc_errors++;
> -			if (status & RxFOVF) {
> -				rtl8169_schedule_work(dev, rtl8169_reset_task);
> -				dev->stats.rx_fifo_errors++;
> -			}
>  			rtl8169_mark_to_asic(desc, rx_buf_sz);
>  		} else {
>  			struct sk_buff *skb;
