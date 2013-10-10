From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] carl9170: fix leaks at failure path in carl9170_usb_probe()
Date: Thu, 10 Oct 2013 20:17:09 +0200
Message-ID: <9668029.9aMApUIsT2@blech>
References: <1380340311-4630-1-git-send-email-khoroshilov@ispras.ru> <52466624.4040106@ispras.ru> <20131010175952.GG2691@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Fabio Estevam <festevam@gmail.com>,
	linux-wireless@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	ldv-project@linuxtesting.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131010175952.GG2691@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, October 10, 2013 01:59:52 PM John W. Linville wrote:
> On Sat, Sep 28, 2013 at 01:16:20AM -0400, Alexey Khoroshilov wrote:
> > On 28.09.2013 00:17, Fabio Estevam wrote:
> > >On Sat, Sep 28, 2013 at 12:51 AM, Alexey Khoroshilov
> > ><khoroshilov@ispras.ru> wrote:
> > >
> > >>-       return request_firmware_nowait(THIS_MODULE, 1, CARL9170FW_NAME,
> > >>+       err = request_firmware_nowait(THIS_MODULE, 1, CARL9170FW_NAME,
> > >>                 &ar->udev->dev, GFP_KERNEL, ar, carl9170_usb_firmware_step2);
> > >>+       if (err) {
> > >>+               usb_put_dev(udev);
> > >>+               usb_put_dev(udev);
> > >You are doing the same free twice.
> > Yes, because it was get twice.
> > >I guess you meant to also free: usb_put_dev(ar->udev)
> > udev and ar->udev are equal, so technically the patch is correct.
> > 
> > I agree that there is some inconsistency, but I would prefer to fix
> > it at usb_get_dev() side with a comment about reasons for the double
> > get.
> 
> What is the reason for the double get?

The idea is:
One (extra) reference protects the asynchronous firmware loader callback
from disappearing "udev".

Regards,
Chr
 
 
