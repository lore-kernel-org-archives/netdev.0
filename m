From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 2/6] driver-core: add driver async_probe support
Date: Tue, 21 Oct 2014 01:43:25 +0200
Message-ID: <CAB=NE6VV97M=iXRQZpGUhEksrqE4JBVDSAU1Wjx_viqatsirmw@mail.gmail.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <1409899047-13045-3-git-send-email-mcgrof@do-not-panic.com> <20140905221029.GA35667@core.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Tejun Heo <tj@kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare <hare@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhi
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140905221029.GA35667@core.coreip.homeip.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/base/bus.c b/drivers/base/bus.c
> index 83e910a..49fe573 100644
> --- a/drivers/base/bus.c
> +++ b/drivers/base/bus.c
> @@ -10,6 +10,7 @@
>   *
>   */
>
> +#include <linux/async.h>
>  #include <linux/device.h>
>  #include <linux/module.h>
>  #include <linux/errno.h>
> @@ -547,15 +548,12 @@ void bus_probe_device(struct device *dev)
>  {
>         struct bus_type *bus = dev->bus;
>         struct subsys_interface *sif;
> -       int ret;
>
>         if (!bus)
>                 return;
>
> -       if (bus->p->drivers_autoprobe) {
> -               ret = device_attach(dev);
> -               WARN_ON(ret < 0);
> -       }
> +       if (bus->p->drivers_autoprobe)
> +               device_initial_probe(dev);
>
>         mutex_lock(&bus->p->mutex);
>         list_for_each_entry(sif, &bus->p->interfaces, node)
> @@ -657,6 +655,17 @@ static ssize_t uevent_store(struct device_driver *drv, const char *buf,
>  }
>  static DRIVER_ATTR_WO(uevent);

Based on my review with my latest changes this is what I was missing,
I'll be sure to address this.

 Luis
