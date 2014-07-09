From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH v8 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Wed, 9 Jul 2014 15:38:00 -0700
Message-ID: <CAKh23FnraikR3apUtrxOWYransQYEFVVJcSaL9d6OWzeWiVT1A@mail.gmail.com>
References: <1403306296-26198-1-git-send-email-isubramanian@apm.com>
	<1403306296-26198-5-git-send-email-isubramanian@apm.com>
	<20140624.223442.1599243407487139839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, patches <patches-qTEPVZfXA3Y@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140624.223442.1599243407487139839.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 24, 2014 at 10:34 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
> Date: Fri, 20 Jun 2014 16:18:16 -0700
>
>> This patch adds network driver for APM X-Gene SoC ethernet.
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
>> Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
>> Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
>
> I really don't like how you handle the hardware descriptors in this
> driver.
>
> You copy back and forth between a software format and the hardware
> format.  That's extremely wasteful and will hurt performance.
>
> Just use the raw format throughout, you can extract the fields when
> you need them.

I agree and I will fix this and resubmit the patches.

>
> You also make two passes when building a hardware descriptor:
>
> 1) write the values
> 2) endian swap
>
> This means you make three memory accesses on every 64-bit word
> in every descriptor you setup, this is really inefficient.
>
> You should just byte swap them in-situ as you build the raw
> descriptors.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
