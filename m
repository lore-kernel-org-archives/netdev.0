From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Silicom bypass driver promote from staging
Date: Thu, 7 Aug 2014 02:46:15 -0700
Message-ID: <CAL3LdT6-OUJOZ4WHDKfS1ytDubDLMv0RaoQGoPjA2fScuYxnUg@mail.gmail.com>
References: <3BFAEADE799AF145974162DF00E013AF018F80FFCF@exchange2010.silicom.local>
	<20140805150957.GC27303@kroah.com>
	<3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Anna Lukin <annal@silicom.co.il>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
To: David Hendel <david@silicom.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:57292 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757238AbaHGJqQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 05:46:16 -0400
Received: by mail-ob0-f172.google.com with SMTP id wn1so2736805obc.17
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2014 02:46:15 -0700 (PDT)
In-Reply-To: <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 7, 2014 at 2:26 AM, David Hendel <david@silicom.co.il> wrote:
> Hello Netdev group,
>
> For the /driver/staging/silicom that we want to promote.
> We have our bypass driver updated and we would like to move forward with integrating it into the kernel mainline We are not sure of what is the best location to have these driver located, as this is not really a network driver.
> The options that we see are:
> driver/misc/silicom/...
> driver/char/silicom/...
> driver/bypass/silicom/....
>
> The description of the functionality of the driver is below per readme of this driver in the /driver/staging/silicom.
>
> Currently in the attached driver we have defined it to be in driver/bypass/silicom/....
> If this is OK with you then we can continue with that. if you thing that it needs to be in another location then we can change the patch.
>
> Let me know how we can proceed with that. what should be the next step.
> -------------
> Theory of Operation:
> The Silicom Bypass Network Interface Cards (NICs) are network cards with paired ports (2 or 4).

Based on the above description alone, the best location of your driver would be:
drivers/net/ethernet/silicom/...

I would suggest submitting patches to move your bypass driver to the
suggested location (drivers/net/ethernet/silicom/) to the netdev
mailing list, and we can go from there.

> The pairs either act as a "wire" allowing the network packets to pass or insert the device in between the two ports.  When paired with the on-board hardware watchdog or other failsafe, they provide high availability for the network in the face of software outages or maintenance.
>
> The software requirements are for a kernel level driver that interfaces with the bypass and watchdog, as well as for control software. User control can be either the provided standalone executable
> (/bin/bpctl) or the API exposed by the Silicom library.
> ----------------------
>
> Regards, David
>
> -----Original Message-----
> From: gregkh@linuxfoundation.org [mailto:gregkh@linuxfoundation.org]
> Sent: Monday, June 09, 2014 11:04 PM
> To: David Hendel
> Subject: Re: FW: ethtool patch to support bypass / fail-to-wire function
>
> On Mon, Jun 09, 2014 at 07:29:08PM +0000, David Hendel wrote:
>> Hello Greg Kroah-Hartman,
>>
>> My name is David Hendel, I am Silicom V.P of R&D and was working with Anna Lukin our senior software developer to incorporate our bypass / Fail-to-Wire functionality into ethtool.
>>
>> We have been working with our partner Citrix in doing that and they
>> think that it will be very valuable if this will be added to the kernel distribution ethtool We have our bypass driver already in the kernel  - /drivers/staging/silicom/ bpctl_mode ...
>
> Ah, I was wondering what was up with that driver.  I wanted to remove it soon as it didn't seem like anyone was working on merging it to the "proper" place in the Linux kernel tree.  Are you planning on helping to clean up the code to get it merged properly soon?
>
>> Per Ben Hutchings we need to work with networking community, not sure
>> if you are the one to approach,
>
> Nope, I'm not a networking developer, try the netdev@vger.kernel.org mailing list, that is where the Linux kernel networking developers are at.
>
> greg k-h
