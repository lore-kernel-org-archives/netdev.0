From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 7/7] switchdev: update documentation on FDB ageing_time
Date: Sun, 20 Sep 2015 08:56:26 -0700
Message-ID: <CAE4R7bCovheUFmync5R+Gr0qnLHp4_jwRsHJY1y6w5-=AnH5=w@mail.gmail.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-8-git-send-email-sfeldma@gmail.com> <55FE0A2C.9040205@cumulusnetworks.com>
 <CAE4R7bD_FchEJ_HuuJcGx0_fqwjxCG_EsYETogVO6O-6uoLj1g@mail.gmail.com> <55FEC19F.80601@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35574 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071AbbITP4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 11:56:47 -0400
Received: by oiww128 with SMTP id w128so47751281oiw.2
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 08:56:46 -0700 (PDT)
In-Reply-To: <55FEC19F.80601@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 20, 2015 at 7:24 AM, roopa <roopa@cumulusnetworks.com> wrote:
> On 9/19/15, 7:21 PM, Scott Feldman wrote:
>>
>> Yes, your switch driver is in user-space so you have to use NTF_USE to
>> refresh the entry since you cannot use the kernel driver model to
>> call_switchdev_notifiers(SWITCHDEV_FDB_ADD, ...).  Consequently, your
>> entries are not marked with NTF_EXT_LEARNED, so this patch is a no-op
>> for you.  You can continue to use the bridge driver to age out your
>> entries.
>
> yes, correct.  I was not really saying this because it will cause us any
> problems.
> I was trying to say this for switchdev in general.
>
>> I'd rather someone add that knob when it's actually needed. When the first
>> in-kernel switchdev driver that wants to use the bridge driver's ageing
>> function, then we can make that adjustment.
>
> I was suggesting the other way around. Keep the default to what is in the
> kernel today and the first in-kernel switchdev driver that wants to age,
> should introduce the ability to not age in the bridge driver (Rocker will
> continue to work as it does today). Because, I am only concerned that rocker
> may end up being the only device that uses the default behavior introduced
> by this patch. And every real hardware uses the bridge driver to age
> (because there are no in kernel examples today).  I am curious to know who
> else is using hardware ageing today.

A driver patch for a (real) hardware device which does the ageing in
hw is around the corner.
