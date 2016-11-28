From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: turn on device when extracting statistics
Date: Mon, 28 Nov 2016 09:11:49 -0500 (EST)
Message-ID: <20161128.091149.2039527154584013771.davem@davemloft.net>
References: <1480068120-22137-1-git-send-email-nikita.yoush@cogentembedded.com>
        <20161127.202945.1759992980026862076.davem@davemloft.net>
        <4ddb5842-0ece-2950-214f-f56db808ffbd@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: 8BIT
Cc: fugang.duan@nxp.com, troy.kisky@boundarydevices.com,
        andrew@lunn.ch, eric@nelint.com, tremyfr@gmail.com,
        johannes@sipsolutions.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, cphealy@gmail.com,
        fabio.estevam@nxp.com
To: nikita.yoush@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56732 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932283AbcK1OLx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 09:11:53 -0500
In-Reply-To: <4ddb5842-0ece-2950-214f-f56db808ffbd@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Date: Mon, 28 Nov 2016 10:06:31 +0300

> 
> 
> 28.11.2016 04:29, David Miller пишет:
>> From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
>> Date: Fri, 25 Nov 2016 13:02:00 +0300
>> 
>>> +	int i, ret;
>>> +
>>> +	ret = pm_runtime_get_sync(&fep->pdev->dev);
>>> +	if (IS_ERR_VALUE(ret)) {
>>> +		memset(data, 0, sizeof(*data) * ARRAY_SIZE(fec_stats));
>>> +		return;
>>> +	}
>> 
>> This really isn't the way to do this.
>> 
>> When the device is suspended and the clocks are going to be stopped,
>> you must fetch the statistic values into a software copy and provide
>> those if the device is suspended when statistics are requested.
> 
> Ok, can do that, although can't see what's wrong with waking device
> here. The situation of requesting stats on down device isn't something
> widely used, thus keeping handling of that as local as possible looks
> better for me.

The issue is the fact that you need error handling at all and might
therefore provide a set of zero stats to the user when that entire
possibility could have been avoided in the first place by recording
the stats at suspend time.
