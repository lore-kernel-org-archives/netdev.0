From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 05/10] drivers: base: Add
 device_find_class()
Date: Thu, 12 Jan 2017 16:21:35 -0500 (EST)
Message-ID: <20170112.162135.441956368122992032.davem@davemloft.net>
References: <20170112034121.27697-1-f.fainelli@gmail.com>
        <20170112034121.27697-6-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, linux@armlinux.org.uk,
        vivien.didelot@savoirfairelinux.com,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112034121.27697-6-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 11 Jan 2017 19:41:16 -0800

> Add a helper function to lookup a device reference given a class name.
> This is a preliminary patch to remove adhoc code from net/dsa/dsa.c and
> make it more generic.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/base/core.c    | 19 +++++++++++++++++++
>  include/linux/device.h |  1 +
>  2 files changed, 20 insertions(+)
> 
> diff --git a/drivers/base/core.c b/drivers/base/core.c
> index 020ea7f05520..3dd6047c10d8 100644
> --- a/drivers/base/core.c
> +++ b/drivers/base/core.c
> @@ -2065,6 +2065,25 @@ struct device *device_find_child(struct device *parent, void *data,
>  }
>  EXPORT_SYMBOL_GPL(device_find_child);
>  
> +static int dev_is_class(struct device *dev, void *class)

I know you are just moving code, but this class argumnet is a string
and thus should be "char *" or even "const char *".
