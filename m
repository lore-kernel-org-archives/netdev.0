From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH -next v1] wireless: ath9k-htc: only load firmware in need
Date: Sat, 1 Sep 2012 13:11:32 +0800
Message-ID: <CACVXFVPX1NB5uJ6yXkNbDWoX4OVdYfRU_=tsWC529-tH+3WfDA@mail.gmail.com>
References: <1345536267-9449-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	"Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Jouni Malinen <jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Vasanthakumar Thiagarajan <vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Senthil Balasubramanian <senthilb-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1345536267-9449-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 21, 2012 at 4:04 PM, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> It is not necessary to hold the firmware memory during the whole
> driver lifetime, and obviously it does waste memory. Suppose there
> are 4 ath9k-htc usb dongles working, kernel has to consume about
> 4*50KBytes RAM to cache firmware for all dongles. After applying the
> patch, kernel only caches one single firmware image in RAM for
> all ath9k-htc devices just during system suspend/resume cycle.
>
> When system is ready for loading firmware, ath9k-htc can request
> the loading from usersapce. During system resume, ath9k-htc still
> can load the firmware which was cached in kernel memory before
> system suspend.
>
> Cc: ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org
> Cc: "Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> Cc: Jouni Malinen <jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> Cc: Vasanthakumar Thiagarajan <vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> Cc: Senthil Balasubramanian <senthilb-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
> v1:
>         fix double free of firmware in failue path of
>         ath9k_hif_usb_firmware_cb

Gentle ping, :-)


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
