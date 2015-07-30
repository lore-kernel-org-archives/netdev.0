From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: [PATCH] net/wireless: enable wiphy device to suspend/resume asynchronously
Date: Thu, 30 Jul 2015 08:55:50 +0300
Message-ID: <CANUX_P3PMsvWCWWciwCsRvf5PqLVEK9d9S=2Gbq+EotVGffEow@mail.gmail.com>
References: <55B9B3BA.6080406@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B9B3BA.6080406@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 30, 2015 at 8:18 AM, Fu, Zhonghui
<zhonghui.fu@linux.intel.com> wrote:
> Enable wiphy device to suspend/resume asynchronously. This can improve
> system suspend/resume speed.
>

How will that impact the timing with respect to the suspend call
coming from the bus?
I think that a few drivers rely on the suspend call of the wiphy
device happening before the suspend call to the bus device.
Not sure though.

> Signed-off-by: Zhonghui Fu <zhonghui.fu@linux.intel.com>
> ---
>  net/wireless/core.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/net/wireless/core.c b/net/wireless/core.c
> index 2a0bbd2..bc5e68f 100644
> --- a/net/wireless/core.c
> +++ b/net/wireless/core.c
> @@ -416,6 +416,7 @@ use_default_name:
>         device_initialize(&rdev->wiphy.dev);
>         rdev->wiphy.dev.class = &ieee80211_class;
>         rdev->wiphy.dev.platform_data = rdev;
> +       device_enable_async_suspend(&rdev->wiphy.dev);
>
>         INIT_LIST_HEAD(&rdev->destroy_list);
>         spin_lock_init(&rdev->destroy_list_lock);
> -- 1.7.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
