From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net] net: mvpp2: Fix clock resource by adding an optional bus clock
Date: Thu, 28 Sep 2017 17:52:19 +0200
Message-ID: <87shf6hlcc.fsf@free-electrons.com>
References: <20170928153923.29003-1-gregory.clement@free-electrons.com>
        <20170928174654.630cfefd@windsurf.lan>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Lunn <andrew@lunn.ch>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Omri Itach <omrii@marvell.com>, linux-kernel@vger.kernel.org,
        Nadav Haklai <nadavh@marvell.com>,
        Shadi Ammouri <shadi@marvell.com>,
        Igal Liberman <igall@marvell.com>,
        =?utf-8?Q?Miqu=C3=A8l?= Raynal <miquel.raynal@free-electrons.com>,
        Hanna Hawa <hannah@marvell.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928174654.630cfefd@windsurf.lan> (Thomas Petazzoni's
        message of "Thu, 28 Sep 2017 17:46:54 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Thomas,
 
 On jeu., sept. 28 2017, Thomas Petazzoni <thomas.petazzoni@free-electrons.com> wrote:

>>  	/* List of pointers to port structures */
>>  	struct mvpp2_port **port_list;
>> @@ -7963,6 +7964,16 @@ static int mvpp2_probe(struct platform_device *pdev)
>>  		err = clk_prepare_enable(priv->mg_clk);
>>  		if (err < 0)
>>  			goto err_gop_clk;
>> +
>> +		priv->axi_clk = devm_clk_get(&pdev->dev, "axi_clk");
>> +		if (IS_ERR(priv->axi_clk)) {
>> +			err = PTR_ERR(priv->axi_clk);
>> +			priv->axi_clk = NULL;
>
> You should handle -EPROBE_DEFER here. Indeed, if we have -EPROBE_DEFER,
> we shouldn't treat it as "the clock doesn't exist, so let's skip it and
> continue", but rather as "the clock exists, but isn't ready to use yet,
> let's try later".

You're totally right, I will send a v2 (I will also fix the other issue
you spotted).

Thanks,

Gregory

>
> Thanks!
>
> Thomas
> -- 
> Thomas Petazzoni, CTO, Free Electrons
> Embedded Linux and Kernel engineering
> http://free-electrons.com
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
