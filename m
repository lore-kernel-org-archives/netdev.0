From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 10/10] net: mvneta: Use the new hwbm framework
Date: Wed, 13 Jan 2016 18:47:25 +0100
Message-ID: <87h9ihwevm.fsf@free-electrons.com>
References: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
	<1452625834-22166-11-git-send-email-gregory.clement@free-electrons.com>
	<CAPv3WKcKK8fS-6koSgV7ABi8bvkRgzaqJDpOETCpGoTc2sWV=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKcKK8fS-6koSgV7ABi8bvkRgzaqJDpOETCpGoTc2sWV=w@mail.gmail.com>
	(Marcin Wojtas's message of "Tue, 12 Jan 2016 23:40:40 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
 
 On mar., janv. 12 2016, Marcin Wojtas <mw@semihalf.com> wrote:

> Hi Gregory,
>
> A quick remark below. All changes look fine to me at a first look, but
> I will test and dig more into code soon.

Great! A test would be nice because I have just did basic tests: mainly an
iperf.

>
>>
>> @@ -3946,11 +3965,6 @@ static int mvneta_probe(struct platform_device *pdev)
>>         dev->priv_flags |= IFF_UNICAST_FLT;
>>         dev->gso_max_segs = MVNETA_MAX_TSO_SEGS;
>>
>> -       err = register_netdev(dev);
>> -       if (err < 0) {
>> -               dev_err(&pdev->dev, "failed to register\n");
>> -               goto err_free_stats;
>> -       }
>
> The purpose of shifting register_netdev() was to be able to obtain
> pp->id from net_device, before mvneta_bm_port_init is called. It is
> needed for proper port - pool mapping control.

I can revert this change, initially I moved this chunk because I wanted
to add a netdev_ops before registering it and this netdev_op depend on
the bm support. As for now I don't have this this netdev_op this change
is pointless. But if in future I need it, then I will look for how to do
it in a different way.

Thanks,


>
>>
>>         pp->id = dev->ifindex;
>>
>> @@ -3965,6 +3979,12 @@ static int mvneta_probe(struct platform_device *pdev)
>>                 }
>>         }
>>
>> +       err = register_netdev(dev);
>> +       if (err < 0) {
>> +               dev_err(&pdev->dev, "failed to register\n");
>> +               goto err_free_stats;
>> +       }
>> +
>>         err = mvneta_init(&pdev->dev, pp);
>>         if (err < 0)
>>                 goto err_netdev;
>
> Best regards,
> Marcin

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
