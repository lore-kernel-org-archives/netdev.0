From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] carl9170: fix leaks at failure path in carl9170_usb_probe()
Date: Sat, 28 Sep 2013 01:17:54 -0300
Message-ID: <CAOMZO5DE0OdXhWNEr2HAswvgryBqP8VNk3+vanwsi38L6pL9OA@mail.gmail.com>
References: <1380340311-4630-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Christian Lamparter <chunkeey@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380340311-4630-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 28, 2013 at 12:51 AM, Alexey Khoroshilov
<khoroshilov@ispras.ru> wrote:

> -       return request_firmware_nowait(THIS_MODULE, 1, CARL9170FW_NAME,
> +       err = request_firmware_nowait(THIS_MODULE, 1, CARL9170FW_NAME,
>                 &ar->udev->dev, GFP_KERNEL, ar, carl9170_usb_firmware_step2);
> +       if (err) {
> +               usb_put_dev(udev);
> +               usb_put_dev(udev);

You are doing the same free twice.

I guess you meant to also free: usb_put_dev(ar->udev)
