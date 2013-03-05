From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend
 fails in system sleep
Date: Tue, 5 Mar 2013 19:07:57 +0800
Message-ID: <CACVXFVMRpf0REYxfi1wtzUpXn2PTCeS6qNfYQP12tW8ca3Sp=g@mail.gmail.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<1362456103-24956-5-git-send-email-ming.lei@canonical.com>
	<87boayqq5c.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <87boayqq5c.fsf@nemi.mork.no>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 5, 2013 at 3:09 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <ming.lei@canonical.com> writes:
>
>> If suspend callback fails in system sleep context, usb core will
>> ignore the failure and let system sleep go ahead further, so
>> this patch doesn't recover device under this situation.
>>
>> Cc: Bj=F8rn Mork <bjorn@mork.no>
>> Signed-off-by: Ming Lei <ming.lei@canonical.com>
>> ---
>>  drivers/net/usb/cdc_mbim.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
>> index 248d2dc..da83546 100644
>> --- a/drivers/net/usb/cdc_mbim.c
>> +++ b/drivers/net/usb/cdc_mbim.c
>> @@ -338,7 +338,7 @@ static int cdc_mbim_suspend(struct usb_interface=
 *intf, pm_message_t message)
>>
>>       if (intf =3D=3D ctx->control && info->subdriver && info->subdr=
iver->suspend)
>>               ret =3D info->subdriver->suspend(intf, message);
>> -     if (ret < 0)
>> +     if (ret < 0 && PMSG_IS_AUTO(msg))
>>               usbnet_resume(intf);
>>
>>  error:
>
> NAK. We if the device cannot suspend, then it cannot do suspend halfw=
ays

Sorry, what do you mean that the device cannot suspend?  If you mean
usb_suspend_device(), its failure is still ignored, and generally it is=
 OK
since the suspend action is driven by upstream port.

> either. Whether the caller will ignore the error or not, is irrelevan=
t.

Anyway, usbnet_resume() can't be called to submit new URBs in
the failure path of system suspend, so the patch should be correct.


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
