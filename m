From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH 3/4] qlge: Reduce debug print output.
Date: Mon, 2 Nov 2009 07:57:44 -0800
Message-ID: <20091102155744.GA10894@linux-ox1b.qlogic.org>
References: <1256940816-27540-1-git-send-email-ron.mercer@qlogic.com> <1256940816-27540-4-git-send-email-ron.mercer@qlogic.com> <1256942686.1917.66.camel@Joe-Laptop.home> <20091102.000354.55192142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "joe@perches.com" <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:17604 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755703AbZKBQED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 11:04:03 -0500
Content-Disposition: inline
In-Reply-To: <20091102.000354.55192142.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave and Joe,

Thanks for your feedback on the printk macro.  I agree there is good
infrastructure for debug printing for network devices.  I will drop this
patch for now.  The main reason I did it this way was to remove compares from the data path without removing the messages.
I will respin the last patch.

Thanks,
Ron

On Mon, Nov 02, 2009 at 12:03:54AM -0800, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Fri, 30 Oct 2009 15:44:46 -0700
> 
> > On Fri, 2009-10-30 at 15:13 -0700, Ron Mercer wrote:
> >> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> > []
> >> diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
> >> index b9f65e0..502c3af 100644
> >> --- a/drivers/net/qlge/qlge.h
> >> +++ b/drivers/net/qlge/qlge.h
> >> @@ -27,6 +27,18 @@
> >>  		dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
> >>  			   "%s: " fmt, __func__, ##args);  \
> >>         } while (0)
> >> +#if 0
> >> +#define QPRINTK_DBG(qdev, nlevel, klevel, fmt, args...)	\
> >> +	do {	\
> >> +		if (!((qdev)->msg_enable & NETIF_MSG_##nlevel))	\
> >> +			;					\
> >> +		else						\
> >> +			dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
> >> +					"%s: " fmt, __func__, ##args);  \
> >> +	} while (0)
> >> +#else
> >> +#define QPRINTK_DBG(qdev, nlevel, klevel, fmt, args...)
> >> +#endif
> > 
> > This uses an inverted test and it doesn't verify the args to
> > dev_printk when not #defined.
> > 
> > How about:
> 
> I also don't like this kind of change for another reason.
> 
> The message levels are pointless if you're going to adhere to them
> or not based upon some CPP define.
> 
> Either do it, or don't.  Like every other driver does.
> 
> If for some reason the default is problematic, adjust the default that
> you pass to netif_msg_init() or, alternatively, adjust what level the
> debugging messages are assigned to.
> 
> We have all of this wonderful, full, infrastructure for message
> levelling.  And you can change the setting either at module load time
> or via ethtool.  The default is also up to you as well.
> 
> And you're going to stick a "#if 0" CPP control in there? :-/
> 
> No way, I absolutely won't accept this kind of change, there is no
> need for it.  There is more than enough dynamic flexibility, both at
> run-time via module option and ethtool message level selections, and
> at compile time via the default you can choose hoever you like.
