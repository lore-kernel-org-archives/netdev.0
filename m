From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH] net: davinci_emac: Replace devm_request_irq with
 request_irq
Date: Fri, 07 Mar 2014 07:44:20 +0100
Message-ID: <FF03B20304B8491A4DB33091@[172.22.2.41]>
References: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
 <20140306.165736.154818699714315258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davinci-linux-open-source@linux.davincidsp.com,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	stable@vger.kernel.org, jon@ringle.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140306.165736.154818699714315258.davem@davemloft.net>
Content-Disposition: inline
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Sent again, sorry for the HTML mail before.]

--On March 06, 2014 16:57 -0500 David Miller <davem@davemloft.net> wrot=
e:

> From: Christian Riesch <christian.riesch@omicron.at>
> Date: Wed, 5 Mar 2014 11:25:28 +0100
>
>> @@ -1641,7 +1640,15 @@ static int emac_dev_open(struct net_device *n=
dev)
>>
>>  rollback:
>>
>> -	dev_err(emac_dev, "DaVinci EMAC: devm_request_irq() failed");
>> +	dev_err(emac_dev, "DaVinci EMAC: request_irq() failed");
>> +
>> +	for (q =3D k; k >=3D 0; k--) {
>> +		for (m =3D i; m >=3D res->start; m--)
>> +			free_irq(m, ndev);
>> +		res =3D platform_get_resource(priv->pdev, IORESOURCE_IRQ, k-1);
>> +		m =3D res->end;
>> +	}
>
> This final assignment in the loop of 'm' is unused?
>
> The inner for() loop always started with "m =3D i;"

This should probably read=C2=A0

i =3D res->end;=C2=A0

I just took the old code without thinking about it. Thanks for catching=
 it.

Christian
=C2=A0
