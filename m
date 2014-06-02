From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: ipconfig: allow IP-Config over DSA devices
Date: Mon, 2 Jun 2014 11:02:31 -0700
Message-ID: <CAGVrzcahuvmqT8Onc_W3UiimUNWqWCWvKKKU2XNCfZ9viNqw1Q@mail.gmail.com>
References: <1401473326-21828-1-git-send-email-f.fainelli@gmail.com> <20140531070436.GA3154@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:59536 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbaFBSDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 14:03:12 -0400
Received: by mail-qa0-f51.google.com with SMTP id w8so3200591qac.38
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 11:03:11 -0700 (PDT)
In-Reply-To: <20140531070436.GA3154@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-31 0:04 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
> Fri, May 30, 2014 at 08:08:45PM CEST, f.fainelli@gmail.com wrote:
>>Hi David, Lennert, Jiri,
>>
>>This small patch allows us to use the kernel IP auto-configuration on DSA
>>enabled devices.
>>
>>I initially started implementing the netdev_upper_dev_link() calls for the
>>DSA slave devices, but ended up realizing that although this might be useful,
>>the other drivers or protocols implementing these master/slave relantionship
>>are the bonding driver and the VLAN code.
>>
>>None of these interfaces (bonding or VLAN) can be created by the kernel
>>without modifications, which means that user-space is there, and so we could
>>pivot_root over a NFS mounted share for instance, hence making the master/slave
>>net_device relationship not so useful for IP-Config.
>>
>>This is not the case with DSA devices which are solely created by the kernel
>>based on platform configuration.
>>
>>Let me know your thoughts. If you feel like something like:
>>netdev_is_upper_dev() or something like that is better.
>
> uppers and lowers should not be used by switches. If they were, it would
> block the usage of ports in bond/bridge/ovs. I did that myself in my
> first RFC patchset but realized that it make no sense.
>
> What I have in mind and I believe that many people nodded to is an
> exported (netlink, sysfs) value of switch id. That can be generated
> randomly or from some hw id. Please see following git tree:
>
> https://github.com/jpirko/net-next-rocker
>
> On the tip, there are rocker patches combined with the switch
> infrastructure patches. The switch id is there implemented for dsa and
> rocker.
>
> This is based on the RFC patchset I sent some while ago on netdev
> mailing list.
>
> Please tell me what do you think.

The way the switch_id attribute is implemented, is currently a
property of the slave aka per-port net_devices, which makes sense.
That does not entirely help me in my case, which is bringing up the
master/parent network device of these slave devices. We are still
missing a "generic" way to tell how a slave per-port network device
relates to its "conduit" network device.
-- 
Florian
