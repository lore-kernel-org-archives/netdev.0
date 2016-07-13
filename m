From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless ucode is loaded
Date: Wed, 13 Jul 2016 09:50:53 +0300
Message-ID: <87eg6yav5e.fsf@purkki.adurom.net>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com>
	<CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>
	<5783E33E.7090205@redhat.com> <1468261650.20877.14.camel@intel.com>
	<57840214.8000904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Grumbach\, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linuxwifi <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Coelho\, Luciano" <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Berg\, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Ivgi\, Chaya Rachel" <chaya.rachel.ivgi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Sharon\, Sara" <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Prarit Bhargava <prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57840214.8000904-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Prarit Bhargava's message of "Mon,
	11 Jul 2016 16:31:16 -0400")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Prarit Bhargava <prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

>> We implement thermal zone because we do support it, but the problem is
>> that we need the firmware to be loaded for that. So you can argue that
>> we should register *later* when the firmware is loaded. But this is
>> really not helping all that much because the firmware can also be
>> stopped at any time. So you'd want us to register / unregister the
>> thermal zone anytime the firmware is loaded / unloaded?
>
> You might have to do that.  I think that if the firmware enables a feature then
> the act of loading the firmware should run the code that enables the feature.
> IMO of course.

But I suspect that the iwlwifi firmware is loaded during interface up
(and unloaded during interface down) and in that case
register/unregister would be happening all the time. That doesn't sound
like a good idea. I would rather try to fix the thermal interface to
handle the cases when the measurement is not available.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
