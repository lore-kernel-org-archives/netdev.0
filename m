From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 0/7] USB: don't recover device if suspend fails in system sleep
Date: Tue, 5 Mar 2013 21:08:09 +0800
Message-ID: <CACVXFVMkztqc_K+8gvPJhU-rC+c_STDyZLDmJZ2p1hLnADDXvg@mail.gmail.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<87fw0aqqel.fsf@nemi.mork.no>
	<CACVXFVM=PcxTLb1-Bo-11Lz0FzthQJTRKt5=sn6W85K9p8xE4A@mail.gmail.com>
	<3703451.5FViJ58GpZ@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3703451.5FViJ58GpZ-7ztolUikljGernLeA6q8OA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 5, 2013 at 8:50 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>>
>> IMO, for autosuspend, that is right, but it is not for system suspend,
>> and the driver's suspend callback can't return in resumed state
>> because the USB core will ignore the failure return value and force
>> to suspend the device.
>
> It seems to me that in this case you just need to make sure that
> suspend() not fail for system suspend. Or revisit the decision to
> ignore failures.

IMO, the current policy is correct.

> In other words, if we don't handle errors, there must be no errors,
> otherwise it doesn't matter what we do in the error case. We'd leave
> the problem to generic layers.

Generic layers can't handle the driver's specific failure.

If driver records its suspend failure state in suspend(), resume()
should and can deal with it without much difficulty.

>
> Furthermore there is a small chance that although the device tree
> is walked, teh system suspend fails for another later reason that
> is not ignored. In that case the drivers need to do error recovery,
> albeit in resume().

Yes,  resume() need to handle the USB system suspend failure
either in normal resume or error recovery, both are basically same.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
