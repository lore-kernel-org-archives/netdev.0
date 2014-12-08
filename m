From: Ming Lei <ming.lei@canonical.com>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 23:18:18 +0800
Message-ID: <CACVXFVPOLfDuqc0nLb-zM8vH618DLXy0xtZbUOn5_XvdxRZSDw@mail.gmail.com>
References: <201411271506.20457@pali>
	<20141127155840.GC24149@kroah.com>
	<20141206124954.GB17289@amd>
	<201412061402.21514@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel@ucw.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201412061402.21514@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 6, 2014 at 9:02 PM, Pali Roh=C3=A1r <pali.rohar@gmail.com> =
wrote:
> On Saturday 06 December 2014 13:49:54 Pavel Machek wrote:

>
>  /**
> + * request_firmware_prefer_user: - prefer usermode helper for loadin=
g firmware
> + * @firmware_p: pointer to firmware image
> + * @name: name of firmware file
> + * @device: device for which firmware is being loaded
> + *
> + * This function works pretty much like request_firmware(), but it p=
refer
> + * usermode helper. If usermode helper fails then it fallback to dir=
ect access.
> + * Usefull for dynamic or model specific firmware data.
> + **/
> +int request_firmware_prefer_user(const struct firmware **firmware_p,
> +                           const char *name, struct device *device)
> +{
> +       int ret;
> +       __module_get(THIS_MODULE);
> +       ret =3D _request_firmware(firmware_p, name, device,
> +                               FW_OPT_UEVENT | FW_OPT_PREFER_USER);
> +       module_put(THIS_MODULE);
> +       return ret;
> +}
> +EXPORT_SYMBOL_GPL(request_firmware_prefer_user);

I'd like to introduce request_firmware_user() which only requests
firmware from user space, and this way is simpler and more flexible
since we have request_firmware_direct() already.

Thanks,
Ming Lei
