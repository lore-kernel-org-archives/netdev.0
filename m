From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v1 1/7] USB: adds comment on suspend callback
Date: Thu, 7 Mar 2013 10:09:17 +0800
Message-ID: <CACVXFVPi8mvUiXuxO71Rjyo2bzOUF8anoORdpHk-1iAjrSHrSw@mail.gmail.com>
References: <1362565557-15884-2-git-send-email-ming.lei@canonical.com>
	<Pine.LNX.4.44L0.1303061012330.1955-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>, Oliver Neukum <oneukum@suse.de>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-input@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:44623 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754434Ab3CGCJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 21:09:20 -0500
In-Reply-To: <Pine.LNX.4.44L0.1303061012330.1955-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 6, 2013 at 11:25 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
> On Wed, 6 Mar 2013, Ming Lei wrote:
>
>> This patch adds comments on interface driver suspend callback
>> to emphasize that the failure return value is ignored by
>> USB core in system sleep context, so do not try to recover
>> device for this case and let resume/reset_resume callback
>> handle the suspend failure if needed.
>
> In this same patch you should also update the kerneldoc for
> usb_suspend_both().  It should mention that errors returned by the
> suspend method for @udev will be ignored during system suspend.

OK.

>
>> Signed-off-by: Ming Lei <ming.lei@canonical.com>
>> ---
>>  include/linux/usb.h |    9 ++++++++-
>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/usb.h b/include/linux/usb.h
>> index 4d22d0f..6e66dc4 100644
>> --- a/include/linux/usb.h
>> +++ b/include/linux/usb.h
>> @@ -978,7 +978,14 @@ struct usbdrv_wrap {
>>   *   the "usbfs" filesystem.  This lets devices provide ways to
>>   *   expose information to user space regardless of where they
>>   *   do (or don't) show up otherwise in the filesystem.
>> - * @suspend: Called when the device is going to be suspended by the system.
>> + * @suspend: Called when the device is going to be suspended by the
>> + *   system either from system sleep or runtime suspend context, and
>> + *   its failure return value will be ignored in system sleep context,
>
> This is an ungrammatical run-on sentence.  s/, and its failure/. The/

OK.

>
>> + *   so do NOT try to recover device for this case. It is suggested
>> + *   the callback always return 0 if resume/reset_resume callback can
>> + *   handle system sususpend failure at default, otherwise driver
>> + *   need to record the suspend failure and let resume/reset_resume
>> + *   handle previous system suspend failure to recover device.
>
> I don't understand what this is supposed to mean.  How about this
> instead?  "so do NOT try to continue using the device if suspend fails
> in this case.  Instead, let the resume or reset-resume routine recover
> from the failure."

Looks your description is more neat, and will take it in v2.


Thanks,
--
Ming Lei
