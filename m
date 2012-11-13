From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [net-next PATCH] net/ethernet: remove useless is_valid_ether_addr
 from drivers ndo_open
Date: Tue, 13 Nov 2012 23:07:53 +0100
Message-ID: <CAGhQ9Vy-3shh9FtpZd9FKmmg_fc5VzzeEg6APRfSQv5fj_Qu0A@mail.gmail.com>
References: <1352843199-24869-1-git-send-email-manabian@gmail.com>
	<20121113135519.1e02be53@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, pcnet32@frontier.com, nicolas.ferre@atmel.com,
	mlindner@marvell.com, nico@fluxnic.net,
	steve.glendinning@shawell.net,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:46500 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232Ab2KMWHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 17:07:54 -0500
Received: by mail-la0-f46.google.com with SMTP id h6so5835625lag.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 14:07:53 -0800 (PST)
In-Reply-To: <20121113135519.1e02be53@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 November 2012 22:55, Stephen Hemminger <shemminger@vyatta.com> wrote:
> On Tue, 13 Nov 2012 22:46:39 +0100
> Joachim Eastwood <manabian@gmail.com> wrote:
>
>> diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
>> index d19a143..ce8d053 100644
>> --- a/drivers/net/ethernet/marvell/skge.c
>> +++ b/drivers/net/ethernet/marvell/skge.c
>> @@ -2524,9 +2524,6 @@ static int skge_up(struct net_device *dev)
>>       size_t rx_size, tx_size;
>>       int err;
>>
>> -     if (!is_valid_ether_addr(dev->dev_addr))
>> -             return -EINVAL;
>> -
>>       netif_info(skge, ifup, skge->netdev, "enabling interface\n");
>>
>>       if (dev->mtu > RX_BUF_SIZE)
>
> This should probably stay since it costs so little and protects
> against a obscure error case.
> skge_up is called from skge_resume on resume from suspend.
> It is possible that the device was zeroed after skge_suspend was
> called.

ah, true. Should have checked that...
I see now that some of the other drivers also makes calls into open
from resume. Guess that those cases should be dropped as well.

Thanks for your feedback.

regards
Joachim Eastwood
