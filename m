From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Wed, 10 Oct 2012 17:48:54 +0800
Message-ID: <CACVXFVMq8-t2o5=M=3xCQEiPFXjvH14g3NtRgOTMYr542d5zXw@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<4085386.s0fOKMaRDP@linux-lqwf.site>
	<CACVXFVM7wPLXy0JL7QDnCaZFidwucTFf3t_38DuwukxWtOESHQ@mail.gmail.com>
	<1631246.gHVDWoZpLi@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1631246.gHVDWoZpLi-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 10, 2012 at 4:39 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> On Wednesday 10 October 2012 16:17:25 Ming Lei wrote:
>> On Wed, Oct 10, 2012 at 1:51 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>
>> > We need to use GFP_NOIO in situations the helper cannot know about.
>> > Please add a gfp_t parameter. Then the caller will solve that.
>>
>> Considered that most of drivers call the helpers in different context, I think
>> it is better to switch the gpf_t flag runtime inside helpers, like below:
>>
>>            if (dev->power.runtime_status == RPM_RESUMING)
>>                    gfp = GFP_NOIO;
>>           else
>>                    gfp = GFP_KERNEL;
>
> You are admirably persistent ;-)

I am only trying to solve the problem more generally, :-)

> If you extended the check to RPM_SUSPENDING it might work,
> but still the problem with error handling exists.

Could you describe the error handling case in a bit detail so
that callers of these helpers can know when GFP_KERNEL
is to be passed and when GFP_NOIO is taken if the gfp
patamerer has to be added?

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
