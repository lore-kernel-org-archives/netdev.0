From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v1 4/7] usbnet: cdc_mbim: don't recover device if suspend
 fails in system sleep
Date: Wed, 6 Mar 2013 21:48:19 +0800
Message-ID: <CACVXFVMS4JNphgcU4oy7VQ1S6AoXQUcpRT2ODE_DP79AsnAY4g@mail.gmail.com>
References: <1362565557-15884-1-git-send-email-ming.lei@canonical.com>
	<1362565557-15884-5-git-send-email-ming.lei@canonical.com>
	<877glkohu2.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <877glkohu2.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 6, 2013 at 8:04 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
>
>> If suspend callback fails in system sleep context, usb core will
>> ignore the failure and let system sleep go ahead further, so
>> this patch doesn't recover device under this situation.
>>
>> Cc: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> ---
>>  drivers/net/usb/cdc_mbim.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
>> index 248d2dc..ec58c2c 100644
>> --- a/drivers/net/usb/cdc_mbim.c
>> +++ b/drivers/net/usb/cdc_mbim.c
>> @@ -338,7 +338,7 @@ static int cdc_mbim_suspend(struct usb_interface=
 *intf, pm_message_t message)
>>
>>       if (intf =3D=3D ctx->control && info->subdriver && info->subdr=
iver->suspend)
>>               ret =3D info->subdriver->suspend(intf, message);
>> -     if (ret < 0)
>> +     if (ret < 0 && PMSG_IS_AUTO(message))
>>               usbnet_resume(intf);
>>
>>  error:
>
> This condition will never happen because the subdriver callback alway=
s
> return 0 if !PMSG_IS_AUTO(message), so adding anything here is purely
> for documentation purposes.  That is OK for me.  But I do not see any
> point adding incomplete or wrong documentation.
>
> The above is incomplete because it ignores the failure and still retu=
rn
> an error. And it is wrong because we ignore an error we cannot possib=
ly
> handle in resume.  Only the subdriver can do that, which is why we mu=
st
> delegate this to the subdriver.
>
> I believe the correct here is to document the fact that we require th=
e
> subdriver->suspend() callback to always return 0 if !PMSG_IS_AUTO(mes=
sage).
> That is best done with a comment. No need to add any redundant code.

Considered that the subdriver might change its return value in future, =
how about
just add the below comment?

        /* TODO: resume() might need to handle suspend failure from sub=
driver */


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
