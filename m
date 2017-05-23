From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v6 net-next 17/17] net: qualcomm: add QCA7000 UART driver
Date: Tue, 23 May 2017 20:16:44 +0200
Message-ID: <053235ad-a963-6a09-ccb0-b643115dee00@gmx.de>
References: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
 <1495545173-22150-18-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, Jakub Kicinski <kubakici@wp.pl>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-serial@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1495545173-22150-18-git-send-email-stefan.wahren@i2se.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 23.05.2017 15:12, Stefan Wahren wrote:


> +}
> +
> +static void qca_uart_remove(struct serdev_device *serdev)
> +{
> +	struct qcauart *qca = serdev_device_get_drvdata(serdev);
> +
> +	netif_carrier_off(qca->net_dev);
> +	cancel_work_sync(&qca->tx_work);
> +	unregister_netdev(qca->net_dev);

Note that it is still possible that the tx work is queued right after cancel_work_sync()
returned and before the net device is unregistered (and thus the check for the net device
being up at the beginning of the tx work function is passed and the function is executed).
I suggest to avoid this possible race by first unregistering the netdevice and then 
calling cancel_work_sync().

Regards,
Lino 
