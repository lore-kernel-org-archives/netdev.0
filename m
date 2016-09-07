From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 0/3] r8152: configuration setting
Date: Wed, 07 Sep 2016 15:51:09 +0200
Message-ID: <87h99rizsi.fsf@miraculix.mork.no>
References: <1394712342-15778-215-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: <netdev@vger.kernel.org>, <nic_swsd@realtek.com>,
        <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
        Oliver Neukum <oliver@neukum.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-215-Taiwan-albertk@realtek.com> (Hayes Wang's
        message of "Wed, 7 Sep 2016 16:12:19 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ CCing Oliver, who AFAIK still is the cdc_ether maintainer and should
  have the final word on this ]

Hayes Wang <hayeswang@realtek.com> writes:

> Some people prefer to use ECM mode rather than vendor mode. Therefore, I =
add
> CONFIG_RTL8152_CONFIG_VALUE in Kconfig. Then, the users could choose the =
USB
> configuration value which they want. The default is to support vendor mode
> only.
>
> Hayes Wang (3):
>   r8152: check hw version first
>   r8152: support ECM mode
>   r8152: add CONFIG_RTL8152_CONFIG_VALUE
>
>  drivers/net/usb/Kconfig |  13 ++
>  drivers/net/usb/r8152.c | 383 +++++++++++++++++++++++++++++++++++++++++-=
------
>  2 files changed, 345 insertions(+), 51 deletions(-)


So this adds a lot of code to work around the issues you introduced by
unnecessarily blacklisting the CDC ECM configuration earlier, and still
makes the r8152 driver handle the device even in ECM mode.

Sorry, but this is a total mess.

Just remove the completely unnecessary blacklist, and let the cdc_ether
driver handle the device if the user selects the ECM configuration.
That't how the USB system works.  There is no need for any code in r8152
to do that.

Ref https://lkml.org/lkml/2014/1/3/57



Bj=C3=B8rn
