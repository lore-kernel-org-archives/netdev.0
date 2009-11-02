From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/4] qlge: Reduce debug print output.
Date: Mon, 02 Nov 2009 00:03:54 -0800 (PST)
Message-ID: <20091102.000354.55192142.davem@davemloft.net>
References: <1256940816-27540-1-git-send-email-ron.mercer@qlogic.com>
	<1256940816-27540-4-git-send-email-ron.mercer@qlogic.com>
	<1256942686.1917.66.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46834
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754187AbZKBIDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 03:03:32 -0500
In-Reply-To: <1256942686.1917.66.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 30 Oct 2009 15:44:46 -0700

> On Fri, 2009-10-30 at 15:13 -0700, Ron Mercer wrote:
>> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> []
>> diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
>> index b9f65e0..502c3af 100644
>> --- a/drivers/net/qlge/qlge.h
>> +++ b/drivers/net/qlge/qlge.h
>> @@ -27,6 +27,18 @@
>>  		dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
>>  			   "%s: " fmt, __func__, ##args);  \
>>         } while (0)
>> +#if 0
>> +#define QPRINTK_DBG(qdev, nlevel, klevel, fmt, args...)	\
>> +	do {	\
>> +		if (!((qdev)->msg_enable & NETIF_MSG_##nlevel))	\
>> +			;					\
>> +		else						\
>> +			dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
>> +					"%s: " fmt, __func__, ##args);  \
>> +	} while (0)
>> +#else
>> +#define QPRINTK_DBG(qdev, nlevel, klevel, fmt, args...)
>> +#endif
> 
> This uses an inverted test and it doesn't verify the args to
> dev_printk when not #defined.
> 
> How about:

I also don't like this kind of change for another reason.

The message levels are pointless if you're going to adhere to them
or not based upon some CPP define.

Either do it, or don't.  Like every other driver does.

If for some reason the default is problematic, adjust the default that
you pass to netif_msg_init() or, alternatively, adjust what level the
debugging messages are assigned to.

We have all of this wonderful, full, infrastructure for message
levelling.  And you can change the setting either at module load time
or via ethtool.  The default is also up to you as well.

And you're going to stick a "#if 0" CPP control in there? :-/

No way, I absolutely won't accept this kind of change, there is no
need for it.  There is more than enough dynamic flexibility, both at
run-time via module option and ethtool message level selections, and
at compile time via the default you can choose hoever you like.
