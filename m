From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless ucode is loaded
Date: Thu, 14 Jul 2016 10:13:04 +0300
Message-ID: <87shvcy9of.fsf@kamboji.qca.qualcomm.com>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com>
	<CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>
	<5783E33E.7090205@redhat.com> <1468261650.20877.14.camel@intel.com>
	<57840214.8000904@redhat.com> <87eg6yav5e.fsf@purkki.adurom.net>
	<57861172.30103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Grumbach\, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Coelho\, Luciano" <luciano.coelho@intel.com>,
	"Berg\, Johannes" <johannes.berg@intel.com>,
	"Ivgi\, Chaya Rachel" <chaya.rachel.ivgi@intel.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon\, Sara" <sara.sharon@intel.com>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:48614 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbcGNHNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 03:13:12 -0400
In-Reply-To: <57861172.30103@redhat.com> (Prarit Bhargava's message of "Wed,
	13 Jul 2016 06:01:22 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prarit Bhargava <prarit@redhat.com> writes:

> On 07/13/2016 02:50 AM, Kalle Valo wrote:
>> Prarit Bhargava <prarit@redhat.com> writes:
>> 
>>>> We implement thermal zone because we do support it, but the problem is
>>>> that we need the firmware to be loaded for that. So you can argue that
>>>> we should register *later* when the firmware is loaded. But this is
>>>> really not helping all that much because the firmware can also be
>>>> stopped at any time. So you'd want us to register / unregister the
>>>> thermal zone anytime the firmware is loaded / unloaded?
>>>
>>> You might have to do that.  I think that if the firmware enables a feature then
>>> the act of loading the firmware should run the code that enables the feature.
>>> IMO of course.
>> 
>> But I suspect that the iwlwifi firmware is loaded during interface up
>> (and unloaded during interface down) and in that case
>> register/unregister would be happening all the time. 
>
> You make it sound like the interface is coming and going a 1000 times a second.
>  Maybe this happens once during runtime & during suspend/resume
>  cycles?

Of course it doesn't happen 1000 times a second but it depends on user
space behaviour. In some cases, when the wlan interface is always up,
the firmware is loaded only once. But in some cases the user space might
change the interface state more frequently.

More so registering services like thermal zone should happen during
driver probe time, not during interface up event.

> What about the cases when the firmware isn't present (and that's what
> lead me to this bug)?

In that case the kernel could return a predefined error value like
-EGAIN or -ENOTDOWN so that the user space knows that a value is not
available at this time (but might be available later).

-- 
Kalle Valo
