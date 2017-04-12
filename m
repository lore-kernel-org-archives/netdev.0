From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: IMX6 FEC connection drops occasionally with 'MDIO read timeout'
Date: Wed, 12 Apr 2017 09:54:12 -0700
Message-ID: <CAJ+vNU1sBrtno7TiXieN0jKaoNXW8EdKtKO49=FfXy8JNSmd6A@mail.gmail.com>
References: <CAJ+vNU1UG2EeJSTStT_BJ+RiRe4a8YwfRgnE6DsRghTLetq_rg@mail.gmail.com>
 <20170407160915.GF23415@lunn.ch> <CAJ+vNU2itJEBMLNz--w9FOis_jMHW9c+UPwU6wh+ma59kbeswA@mail.gmail.com>
 <CAOMZO5DnKfNF__HThRBMix-yr6X9-x0VOVm57oeCQ2iwyL8gzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Lucas Stach <l.stach@pengutronix.de>,
        Fugang Duan <fugang.duan@nxp.com>,
        Koen Vandeputte <koen.vandeputte@ncentric.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38613 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754582AbdDLQyO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 12:54:14 -0400
Received: by mail-wm0-f51.google.com with SMTP id t189so28882428wmt.1
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 09:54:14 -0700 (PDT)
In-Reply-To: <CAOMZO5DnKfNF__HThRBMix-yr6X9-x0VOVm57oeCQ2iwyL8gzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 9:26 AM, Fabio Estevam <festevam@gmail.com> wrote:
> Hi Tim,
>
> On Wed, Apr 12, 2017 at 1:15 PM, Tim Harvey <tharvey@gateworks.com> wrote:
>>
>> Andrew,
>>
>> Thanks for the reply. Your talking about suspend/resume power
>> management right? The users reporting this were not using
>> suspend/resume.
>>
>> With regards to clock are you talking about the IPG clock? Is there
>> any other way that would get turned off other than fec suspend/resume?
>
> Yes, through pm_runtime.
>
> Can you check if this quick debug change help?
>
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3606,8 +3606,6 @@ static int __maybe_unused
> fec_runtime_suspend(struct device *dev)
>         struct net_device *ndev = dev_get_drvdata(dev);
>         struct fec_enet_private *fep = netdev_priv(ndev);
>
> -       clk_disable_unprepare(fep->clk_ipg);
> -
>         return 0;
>  }
>
>
> If you don't see the problem with it, then it means we need to fix the
> pm runtime support in this driver.
>
> Most likely pm runtime is turning off the clocks when it should not.

Fabio,

Ok, I understand now. We will disable the IPG clock disable and see if
that makes a difference.

Tim
