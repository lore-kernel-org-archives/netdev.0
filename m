From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 35/50] media: usb: cx231xx: spin_lock in complete() cleanup
Date: Sat, 27 Jul 2013 17:34:07 +0800
Message-ID: <CACVXFVMHecbxaGWe6-EeF-sDXRx0GnPHb4shRYOQxUXPbRMyGg@mail.gmail.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
	<1373533573-12272-36-git-send-email-ming.lei@canonical.com>
	<51F2878E.90705@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Hans Verkuil <hans.verkuil@cisco.com>
To: Hans Verkuil <hverkuil@xs4all.nl>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <51F2878E.90705@xs4all.nl>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 26, 2013 at 10:28 PM, Hans Verkuil <hverkuil@xs4all.nl> wrote:
>
>
> On 07/11/2013 11:05 AM, Ming Lei wrote:
>> Complete() will be run with interrupt enabled, so change to
>> spin_lock_irqsave().
>>
>> Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
>> Cc: Hans Verkuil <hans.verkuil@cisco.com>
>> Cc: linux-media@vger.kernel.org
>> Signed-off-by: Ming Lei <ming.lei@canonical.com>
>> ---
>>  drivers/media/usb/cx231xx/cx231xx-audio.c |    6 ++++++
>>  drivers/media/usb/cx231xx/cx231xx-core.c  |   10 ++++++----
>>  drivers/media/usb/cx231xx/cx231xx-vbi.c   |    5 +++--
>>  3 files changed, 15 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/media/usb/cx231xx/cx231xx-audio.c b/drivers/media/usb/cx231xx/cx231xx-audio.c
>> index 81a1d97..58c1b5c 100644
>> --- a/drivers/media/usb/cx231xx/cx231xx-audio.c
>> +++ b/drivers/media/usb/cx231xx/cx231xx-audio.c
>> @@ -136,6 +136,7 @@ static void cx231xx_audio_isocirq(struct urb *urb)
>>               stride = runtime->frame_bits >> 3;
>>
>>               for (i = 0; i < urb->number_of_packets; i++) {
>> +                     unsigned long flags;
>>                       int length = urb->iso_frame_desc[i].actual_length /
>>                                    stride;
>>                       cp = (unsigned char *)urb->transfer_buffer +
>> @@ -158,6 +159,7 @@ static void cx231xx_audio_isocirq(struct urb *urb)
>>                                      length * stride);
>>                       }
>>
>> +                     local_irq_save(flags);
>>                       snd_pcm_stream_lock(substream);
>
> Can't you use snd_pcm_stream_lock_irqsave here?

Sure, that is already in my mind, :-)

> Ditto for the other media drivers where this happens: em28xx and tlg2300.

Yes.

>
> I've reviewed the media driver changes and they look OK to me, so if
> my comment above is fixed, then I can merge them for 3.12. Or are these
> changes required for 3.11?

These are for 3.12.

I will send out v2 next week, and thanks for your review.

Thanks,
--
Ming Lei
