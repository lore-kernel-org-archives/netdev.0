From: Natarajan Gurumoorthy <natg@google.com>
Subject: Re: [PATCH] net-tg3: Initialize REG_BASE_ADDR at PCI config offset
 120 to 0
Date: Tue, 10 Dec 2013 07:01:55 -0800
Message-ID: <CAGmqidnusPSYt9GHfQVs7SP620jyEN=Aicr1jS3Esb9C5Ov2wA@mail.gmail.com>
References: <1386614601-9453-1-git-send-email-natg@google.com>
	<1386615608.1752.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<CAGmqidkxoi9EEe0uC18QQUXwjFP1e_1MXL7VPk+NtU-Ta6FGUg@mail.gmail.com>
	<52A633B4.9000307@cogentembedded.com>
	<1386623253.1752.6.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<1386658724.1752.19.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	nsujir@broadcom.com, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:49691 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766Ab3LJPB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 10:01:56 -0500
Received: by mail-vc0-f179.google.com with SMTP id ie18so4621549vcb.38
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 07:01:56 -0800 (PST)
In-Reply-To: <1386658724.1752.19.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael,
     The only time I see crashes is after the tg3 driver has been
loaded into the system. I our use case we are poking around
/sys/devices/pcixxxx/......../config.
     I guess you will incorporate the original patch into the driver
and we can abandon this patch.

Regards
Nat


On Mon, Dec 9, 2013 at 10:58 PM, Michael Chan <mchan@broadcom.com> wrote:
> On Mon, 2013-12-09 at 13:07 -0800, Michael Chan wrote:
>> On Tue, 2013-12-10 at 00:18 +0300, Sergei Shtylyov wrote:
>> > >        We had crashes when the PCI config space got scanned via
>> > > /sys/devices/pcixxxx/....../config.
>> >
>> > > I agree that this fix will not help if the scan happens before the tg3
>> > > driver gets loaded.
>> >
>> >     Then perhaps a better place for such fixup would be a PCI quirk?
>> >
>> Yes, I agree.  Thanks.
>>
>
> On second thought, I think your original patch should be sufficient and
> we don't need to add the PCI quirk to cover so many devices.  The reason
> is that indirect access needs to be explicitly enabled in the
> MISC_HOST_CTRL (0x68) register.  The default value for register 0x68
> should have indirect access disabled.
>
> Nat, does this match what you're seeing?  Did you ever see any system
> crash before tg3 loads?
>



-- 
Regards
Nat Gurumoorthy AB6SJ
