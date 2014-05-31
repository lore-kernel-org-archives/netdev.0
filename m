From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net: ipconfig: allow IP-Config over DSA devices
Date: Sat, 31 May 2014 09:04:36 +0200
Message-ID: <20140531070436.GA3154@minipsycho.orion>
References: <1401473326-21828-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, buytenh@wantstofly.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:49675 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbaEaHEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 03:04:39 -0400
Received: by mail-wg0-f46.google.com with SMTP id n12so2931056wgh.5
        for <netdev@vger.kernel.org>; Sat, 31 May 2014 00:04:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1401473326-21828-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 30, 2014 at 08:08:45PM CEST, f.fainelli@gmail.com wrote:
>Hi David, Lennert, Jiri,
>
>This small patch allows us to use the kernel IP auto-configuration on DSA
>enabled devices.
>
>I initially started implementing the netdev_upper_dev_link() calls for the
>DSA slave devices, but ended up realizing that although this might be useful,
>the other drivers or protocols implementing these master/slave relantionship
>are the bonding driver and the VLAN code.
>
>None of these interfaces (bonding or VLAN) can be created by the kernel
>without modifications, which means that user-space is there, and so we could
>pivot_root over a NFS mounted share for instance, hence making the master/slave
>net_device relationship not so useful for IP-Config.
>
>This is not the case with DSA devices which are solely created by the kernel
>based on platform configuration.
>
>Let me know your thoughts. If you feel like something like:
>netdev_is_upper_dev() or something like that is better.

uppers and lowers should not be used by switches. If they were, it would
block the usage of ports in bond/bridge/ovs. I did that myself in my
first RFC patchset but realized that it make no sense.

What I have in mind and I believe that many people nodded to is an
exported (netlink, sysfs) value of switch id. That can be generated
randomly or from some hw id. Please see following git tree:

https://github.com/jpirko/net-next-rocker

On the tip, there are rocker patches combined with the switch
infrastructure patches. The switch id is there implemented for dsa and
rocker.

This is based on the RFC patchset I sent some while ago on netdev
mailing list.

Please tell me what do you think.

Thanks.

Jiri

>
>Thanks!
>
>Florian Fainelli (1):
>  net: ipconfig: handle DSA enabled network devices
>
> net/ipv4/ipconfig.c | 7 ++++---
> 1 file changed, 4 insertions(+), 3 deletions(-)
>
>-- 
>1.9.1
>
