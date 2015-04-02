From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 01/26] switchdev: introduce get/set attrs ops
Date: Thu, 2 Apr 2015 10:52:28 -0700
Message-ID: <CAE4R7bD9-H_U3ys9hsOx=o51b4rTjjyq3BYBXMmSeXRrvRupSQ@mail.gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
	<1427962212-18411-2-git-send-email-sfeldma@gmail.com>
	<CAGVrzcZvzWDeV7XvZx13fK_u0oYD=mAJKQ5JUNm9UhirBqAHow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:34872 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbbDBRw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 13:52:28 -0400
Received: by qgh3 with SMTP id 3so75753825qgh.2
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 10:52:28 -0700 (PDT)
In-Reply-To: <CAGVrzcZvzWDeV7XvZx13fK_u0oYD=mAJKQ5JUNm9UhirBqAHow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 2, 2015 at 2:09 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> [snip]
>
>> +       int err = -EOPNOTSUPP;
>> +
>> +       if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
>> +               return err;
>
> That check is currently going to prevent DSA from working, since we do
> not yet advertise NETIF_HW_SWITCH_OFFLOAD (which should be fixed). In
> general, though I am not sure this is entirely desirable to check that
> here for multiple reasons:
>
> - stacked devices typically propagate lower devices dev->features, but
> if they are purposely not doing it, this might start breaking
> - is not that check, used as it is now, that unconditionally, end-up
> being redundant with e.g: getting the switch device id to identify
> this net_device as a switch port net_device?
>
> I kind of preferred when we had this moved into the
> __swdev_attr_{get,set} caller, such we had finer control over whether
> or not checking for these kinds of features makes sense for a
> particular operation.

I dropped it in my v1 patch set all together, but then it came back in
v2.  I understand how it works, giving the user the ability to turn
on/off offload support on a port at run-time, but I don't understand
the application.  I agree with you that we already have finer-grained
ability to know if a sub-feature is supported or not based on what the
driver implements (like switch ID or STP state).  I don't know what
this master switch is used for.  Why would the user turn off
offloading on a port at run-time after the device has already been
programmed with some offloading tasks?  What tells the device to stop
those offloads now.  And then later, the user flips the switch to turn
back on offloads on the port.   How do we restore the device?

Roopa, can you help us understand how NETIF_F_HW_SWITCH_OFFLOAD is used?
