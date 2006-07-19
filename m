From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH RFC]rfkill - Hardware button support for Wireless cards
Date: Wed, 19 Jul 2006 13:32:53 +0200
Message-ID: <a32f33a40607190432x3c9aa74dh7421786032adf37c@mail.gmail.com>
References: <a32f33a40607090849h737287a0k9f4d95669aa0ce9c@mail.gmail.com>
	 <200607110034.47944.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Vojtech Pavlik" <vojtech@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:28562 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932541AbWGSLcy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 07:32:54 -0400
Received: by py-out-1112.google.com with SMTP id s49so245571pyc
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2006 04:32:53 -0700 (PDT)
To: "Stefan Rompf" <stefan@loplof.de>
In-Reply-To: <200607110034.47944.stefan@loplof.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > I have been quite busy lately, hence the reason for this late continuance
> > of the Hardware button support for Wireless cards discussion.
> > I have CC'ed the people who discussed this in earlier threads.
>
> no problem. Look good, just one thing I'm missing:
>
> > +     For each registered hardware button an input device will be created.
> > +     If this input device has been opened by the user, rfkill will send a
> > +     signal to userspace instead of the hardware about the new button
> > +     status. This will allow userpace to perform the correct steps
> > +     in order to bring down all interfaces.
>
> > +             if (rfkill->input_dev->users) {
> > +                     input_report_key(rfkill->input_dev,
> > +                             KEY_RFKILL, new_status);
> > +                     input_sync(rfkill->input_dev);
>
> Shouldn't there be a continue to avoid calling enable/disable_radio()?

True, totally overlooked that part. Will fix this immediately.

> > +             }
>
> Stefan
>
> PS: This rfkill stuff is really caught between two stools. Sending a netlink
> event for the device with an additional TLV for radio button status seems as
> valid as sending an input event...

Hmm not sure about this one. Personally I would think that support for
a button would belong more to the input layer. Even when the button
would only be usefull for networking.

ivo
