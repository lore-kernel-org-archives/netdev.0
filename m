From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 01/26] switchdev: introduce get/set attrs ops
Date: Thu, 2 Apr 2015 02:09:05 -0700
Message-ID: <CAGVrzcZvzWDeV7XvZx13fK_u0oYD=mAJKQ5JUNm9UhirBqAHow@mail.gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com> <1427962212-18411-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	sridhar.samudrala@intel.com, "Arad, Ronen" <ronen.arad@intel.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33418 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbbDBJJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 05:09:46 -0400
Received: by obvd1 with SMTP id d1so120216856obv.0
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 02:09:46 -0700 (PDT)
In-Reply-To: <1427962212-18411-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

> +       int err = -EOPNOTSUPP;
> +
> +       if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
> +               return err;

That check is currently going to prevent DSA from working, since we do
not yet advertise NETIF_HW_SWITCH_OFFLOAD (which should be fixed). In
general, though I am not sure this is entirely desirable to check that
here for multiple reasons:

- stacked devices typically propagate lower devices dev->features, but
if they are purposely not doing it, this might start breaking
- is not that check, used as it is now, that unconditionally, end-up
being redundant with e.g: getting the switch device id to identify
this net_device as a switch port net_device?

I kind of preferred when we had this moved into the
__swdev_attr_{get,set} caller, such we had finer control over whether
or not checking for these kinds of features makes sense for a
particular operation.
--
Florian
