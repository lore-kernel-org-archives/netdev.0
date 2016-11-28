From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: Re: [PATCH] net: fec: turn on device when extracting statistics
Date: Mon, 28 Nov 2016 10:06:31 +0300
Message-ID: <4ddb5842-0ece-2950-214f-f56db808ffbd@cogentembedded.com>
References: <1480068120-22137-1-git-send-email-nikita.yoush@cogentembedded.com>
 <20161127.202945.1759992980026862076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: fugang.duan@nxp.com, troy.kisky@boundarydevices.com,
        andrew@lunn.ch, eric@nelint.com, tremyfr@gmail.com,
        johannes@sipsolutions.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, cphealy@gmail.com,
        Fabio Estevam <fabio.estevam@nxp.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161127.202945.1759992980026862076.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



28.11.2016 04:29, David Miller пишет:
> From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
> Date: Fri, 25 Nov 2016 13:02:00 +0300
> 
>> +	int i, ret;
>> +
>> +	ret = pm_runtime_get_sync(&fep->pdev->dev);
>> +	if (IS_ERR_VALUE(ret)) {
>> +		memset(data, 0, sizeof(*data) * ARRAY_SIZE(fec_stats));
>> +		return;
>> +	}
> 
> This really isn't the way to do this.
> 
> When the device is suspended and the clocks are going to be stopped,
> you must fetch the statistic values into a software copy and provide
> those if the device is suspended when statistics are requested.

Ok, can do that, although can't see what's wrong with waking device
here. The situation of requesting stats on down device isn't something
widely used, thus keeping handling of that as local as possible looks
better for me.
