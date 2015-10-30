From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Fri, 30 Oct 2015 22:03:31 +0000
Message-ID: <BN1PR0301MB07707C038A4411BD4DF24DE3CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <06b508cbb6b949f4b3e13e7797948e56@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	<20140623131723.GA7026@aepfle.de>
	<5fb9ddebb68d456ab87979b5cc3830ec@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	<20140623.131018.1349792926453695313.davem@davemloft.net>
	<CAFLxGvwjhxxc2OgerCeF4nmvpbTV1-XttUZ2poaDLFWcBpaOxw@mail.gmail.com>
	<BN1PR0301MB077055A8DD93983AF1C8E31ACA200@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <878u6ksjzg.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Richard Weinberger <richard.weinberger@gmail.com>,
	David Miller <davem@davemloft.net>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0139.outbound.protection.outlook.com ([207.46.100.139]:22336
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932138AbbJ3WDe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 18:03:34 -0400
In-Reply-To: <878u6ksjzg.fsf@vitty.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Friday, October 30, 2015 6:56 AM
> To: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: Richard Weinberger <richard.weinberger@gmail.com>; David Miller
> <davem@davemloft.net>; olaf@aepfle.de; jasowang@redhat.com; driverdev-
> devel@linuxdriverproject.org; LKML <linux-kernel@vger.kernel.org>;
> netdev@vger.kernel.org
> Subject: Re: [PATCH net-next] hyperv: Add handler for
> RNDIS_STATUS_NETWORK_CHANGE event
> 
> Haiyang Zhang <haiyangz@microsoft.com> writes:
> 
> >> -----Original Message-----
> >> From: Richard Weinberger [mailto:richard.weinberger@gmail.com]
> >> Sent: Tuesday, October 27, 2015 6:36 PM
> >> To: David Miller <davem@davemloft.net>
> >> Cc: Haiyang Zhang <haiyangz@microsoft.com>; olaf@aepfle.de; Greg
> Kroah-
> >> Hartman <greg@kroah.com>; netdev@vger.kernel.org; jasowang@redhat.com;
> >> driverdev-devel@linuxdriverproject.org; LKML <linux-
> >> kernel@vger.kernel.org>
> >> Subject: Re: [PATCH net-next] hyperv: Add handler for
> >> RNDIS_STATUS_NETWORK_CHANGE event
> >>
> >> On Mon, Jun 23, 2014 at 10:10 PM, David Miller <davem@davemloft.net>
> >> wrote:
> >> > From: Haiyang Zhang <haiyangz@microsoft.com>
> >> > Date: Mon, 23 Jun 2014 16:09:59 +0000
> >> >
> >> >> So, what's the equivalent or similar command to "network restart"
> on
> >> SLES12? Could
> >> >> you update the command line for the usermodehelper when porting
> this
> >> patch to SLES
> >> >> 12?
> >> >
> >> > No, you are not going to keep the usermodehelper invocation in your
> >> driver
> >> > please remove it.  It is absolutely inappropriate, and I strictly
> do
> >> not want
> >> > to keep it in there because other people will copy it and then
> we'll
> >> have a
> >> > real mess on our hands.
> >>
> >> Sorry for digging up this old thread.
> >> While talking with some guys about usermodehelper abuses I came
> across
> >> this gem.
> >> Mainline still contains that "/etc/init.d/network restart" code.
> >> Haiyang, care to cleanup?
> >
> > Hi Richard and others,
> >
> > Thanks for the reminder. I will clean up the usermode helper.
> >
> > Do you have suggestions of trigger DHCP refresh from kernel mode? Any
> > sample code in the existing kernel code?
> >
> 
> I think it's wrong to call dhcp refresh from kernel. What happens when
> we reconnect normal hardware adapter to another network? Link goes down
> and then up and userspace is supposed to react accordingly. I think we
> should emulate something similar for RNDIS_STATUS_NETWORK_CHANGE.

When link is down physically for a few seconds, the DHCP will automatically 
refresh. I will add code to emulate this. There were some discussions around 
this and other possibilities previously... I agree emulating what happens 
with physically plug/unplug a cable is a reasonable way to trigger the DHCP 
refresh.

Thanks,
- Haiyang
