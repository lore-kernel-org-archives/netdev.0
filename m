From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 7/7] switchdev: update documentation on FDB ageing_time
Date: Sun, 20 Sep 2015 07:24:31 -0700
Message-ID: <55FEC19F.80601@cumulusnetworks.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com> <1442606151-50429-8-git-send-email-sfeldma@gmail.com> <55FE0A2C.9040205@cumulusnetworks.com> <CAE4R7bD_FchEJ_HuuJcGx0_fqwjxCG_EsYETogVO6O-6uoLj1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34856 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbbITOYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 10:24:35 -0400
Received: by pacfv12 with SMTP id fv12so94528586pac.2
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 07:24:34 -0700 (PDT)
In-Reply-To: <CAE4R7bD_FchEJ_HuuJcGx0_fqwjxCG_EsYETogVO6O-6uoLj1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/19/15, 7:21 PM, Scott Feldman wrote:
> Yes, your switch driver is in user-space so you have to use NTF_USE to
> refresh the entry since you cannot use the kernel driver model to
> call_switchdev_notifiers(SWITCHDEV_FDB_ADD, ...).  Consequently, your
> entries are not marked with NTF_EXT_LEARNED, so this patch is a no-op
> for you.  You can continue to use the bridge driver to age out your
> entries.
yes, correct.  I was not really saying this because it will cause us any 
problems.
I was trying to say this for switchdev in general.

> I'd rather someone add that knob when it's actually needed. When the 
> first in-kernel switchdev driver that wants to use the bridge driver's 
> ageing function, then we can make that adjustment. 
I was suggesting the other way around. Keep the default to what is in 
the kernel today and the first in-kernel switchdev driver that wants to age,
should introduce the ability to not age in the bridge driver (Rocker 
will continue to work as it does today). Because, I am only concerned 
that rocker may end up being the only device that uses the default 
behavior introduced by this patch. And every real hardware uses the 
bridge driver to age (because there are no in kernel examples today).  I 
am curious to know who else is using hardware ageing today.
