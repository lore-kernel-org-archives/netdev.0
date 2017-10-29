From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH] sr9800: Use common error handling code in
 sr9800_phy_powerup()
Date: Sun, 29 Oct 2017 13:03:41 +0100
Message-ID: <0600e4f9-dd53-158c-556b-8a87dfc928e6@users.sourceforge.net>
References: <10f2b5a4-1dbd-2c4f-caaa-4225dff35296@users.sourceforge.net>
 <CAMuHMdU6K+KPZvsStfwPev9Z5v1RRYAwLr04FHjmeC=VUEMC+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Ungerer <gerg@linux-m68k.org>,
        Liu Junliang <liujunliang_ljl@163.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-usb@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdU6K+KPZvsStfwPev9Z5v1RRYAwLr04FHjmeC=VUEMC+Q@mail.gmail.com>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> @@ -700,10 +700,9 @@ static int sr9800_phy_powerup(struct usbnet *dev)
>>
>>         /* set the embedded Ethernet PHY in power-up state */
>>         ret = sr_sw_reset(dev, SR_SWRESET_IPRL);
>> -       if (ret < 0) {
>> -               netdev_err(dev->net, "Failed to reset PHY: %d\n", ret);
>> -               return ret;
>> -       }
>> +       if (ret < 0)
>> +               goto report_reset_failure;
> 
> So now I have to look below to see what error handling it does...

Yes. - Can this be an usual consequence if you apply information from
the section “7) Centralized exiting of functions” in the document
“coding-style.rst” a bit more?



> Hence I prefer the original version, which had _less_ lines of code...

My update suggestion is only one line “bigger” in this case, isn't it?

I propose an other source code layout so that a bit smaller executable
object code could be achieved.
Do find such a software design direction feasible?

Regards,
Markus
