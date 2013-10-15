From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 4/5] net: macb: Use devm_request_irq()
Date: Wed, 16 Oct 2013 00:38:06 +0400
Message-ID: <525DA7AE.8030102@cogentembedded.com>
References: <1381795140-10792-1-git-send-email-soren.brinkmann@xilinx.com> <1381795140-10792-5-git-send-email-soren.brinkmann@xilinx.com> <525D95A4.3020706@cogentembedded.com> <ffb65abe-36e2-45c3-9d40-02050545184d@TX2EHSMHS038.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michal Simek <michal.simek@xilinx.com>
To: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ffb65abe-36e2-45c3-9d40-02050545184d@TX2EHSMHS038.ehs.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/2013 12:20 AM, S=C3=B6ren Brinkmann wrote:

>>> Use the device managed interface to request the IRQ, simplifying er=
ror
>>> paths.

>>> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
>>> ---
>>>   drivers/net/ethernet/cadence/macb.c | 8 +++-----
>>>   1 file changed, 3 insertions(+), 5 deletions(-)

>>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethe=
rnet/cadence/macb.c
>>> index 436aecc31732..603844b1d483 100644
>>> --- a/drivers/net/ethernet/cadence/macb.c
>>> +++ b/drivers/net/ethernet/cadence/macb.c
>>> @@ -1825,7 +1825,8 @@ static int __init macb_probe(struct platform_=
device *pdev)
>>>   	}
>>>
>>>   	dev->irq =3D platform_get_irq(pdev, 0);
>>> -	err =3D request_irq(dev->irq, macb_interrupt, 0, dev->name, dev);
>>> +	err =3D devm_request_irq(&pdev->dev, dev->irq, macb_interrupt, 0,
>>> +			dev->name, dev);

>>     You should start the continuation line right under &.

> Actually this one is a good example why I don't do such alignment: Yo=
u
> do a simple search & replace - in this case request_irq ->
> devm_request_irq - and all alignment is gone.

    I didn't understand why this is a good example. In this case you br=
oke the=20
line yourself and did it incorrectly, not following the networking codi=
ng=20
style which assumes Emacs-style alignment for broken lines.

> 	S=C3=B6ren

WBR, Sergei
