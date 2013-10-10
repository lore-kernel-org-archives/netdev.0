From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] carl9170: fix leaks at failure path in
 carl9170_usb_probe()
Date: Thu, 10 Oct 2013 13:59:52 -0400
Message-ID: <20131010175952.GG2691@tuxdriver.com>
References: <1380340311-4630-1-git-send-email-khoroshilov@ispras.ru>
 <CAOMZO5DE0OdXhWNEr2HAswvgryBqP8VNk3+vanwsi38L6pL9OA@mail.gmail.com>
 <52466624.4040106@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fabio Estevam <festevam@gmail.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	linux-wireless@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52466624.4040106@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 28, 2013 at 01:16:20AM -0400, Alexey Khoroshilov wrote:
> On 28.09.2013 00:17, Fabio Estevam wrote:
> >On Sat, Sep 28, 2013 at 12:51 AM, Alexey Khoroshilov
> ><khoroshilov@ispras.ru> wrote:
> >
> >>-       return request_firmware_nowait(THIS_MODULE, 1, CARL9170FW_NAME,
> >>+       err = request_firmware_nowait(THIS_MODULE, 1, CARL9170FW_NAME,
> >>                 &ar->udev->dev, GFP_KERNEL, ar, carl9170_usb_firmware_step2);
> >>+       if (err) {
> >>+               usb_put_dev(udev);
> >>+               usb_put_dev(udev);
> >You are doing the same free twice.
> Yes, because it was get twice.
> >I guess you meant to also free: usb_put_dev(ar->udev)
> udev and ar->udev are equal, so technically the patch is correct.
> 
> I agree that there is some inconsistency, but I would prefer to fix
> it at usb_get_dev() side with a comment about reasons for the double
> get.

What is the reason for the double get?

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
