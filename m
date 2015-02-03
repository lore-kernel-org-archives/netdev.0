From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: rocker: Change netdev names to include slot number
Date: Tue, 03 Feb 2015 09:06:16 -0700
Message-ID: <54D0F1F8.9050500@gmail.com>
References: <1422856985-16530-1-git-send-email-dsahern@gmail.com>	<CAE4R7bA0Ea9zugm=OR0EN2qSeoiROEoMiYZ-5YMwd9UdS4L0Sg@mail.gmail.com>	<54CFEF20.8060300@gmail.com>	<54CFF420.3090603@gmail.com>	<54CFF5B3.7070509@gmail.com> <CAE4R7bArt7+C-kHJ7UXFo4w9feG0C_uZqQ7n8KC0brSXhqX3gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:40224 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965550AbbBCQGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 11:06:18 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so25318869igb.0
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 08:06:17 -0800 (PST)
In-Reply-To: <CAE4R7bArt7+C-kHJ7UXFo4w9feG0C_uZqQ7n8KC0brSXhqX3gg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/2/15 10:46 PM, Scott Feldman wrote:
>> [root@f21 ~]# cat /sys/devices/virtual/net/sw5p0/phys_port_id
>> cat: /sys/devices/virtual/net/sw5p0/phys_port_id: Operation not supported
>
> We should implement .ndo_get_phys_port_id in rocker to return a unique
> name for the port, which can then be used in udev script to name
> interface.  When rocker device is instantiated, a unique switch name
> is given on qemu cmd line, for example "sw1".  Rocker device could
> return that string to the driver, or even combine that string with the

Right. That's what I went looking for at first and noticed that info is 
not pushed to the driver. And then I know at least one vendor puts the 
slot id in interface names which is the reason I went for the PCI slot id.

> port index to have "sw1p1".  The second instantiated rocker device
> would give up "sw2px" port names.

And yes, adding the port index to the above name -- though ideally 
starting at 1 and not 0.

>
> A real switch with a physical port than can be split, or when multiple
> ports are ganged to form one mega port, letting the device pick a
> unique name is probably best.  For example, splitting a single
> physical 40Gb port into 4 10Gb ports would present 4 kernel
> interfaces, but we probably want to use the base port in the naming,
> so we'd have something like "sw1p1s1" to mean switch 1, front panel
> port 1, split port 1.  Letting the device name the ports on current
> port configuration of the port will keep driver/kernel simple, and let
> udev be the final name chooser.

Exactly. When you add in break out ports to the mix having sane, logical 
default names (without udev) makes life easier. That was my ultimate 
intent here - logical default names that udev or a user could then 
modify if so desired.

But anyways, since the request is to have udev do the naming I need to 
come back to it. A quick search on the systemd web site did not stumble 
onto examples I could use, so I need to put this on the back burner 
until I have time to dig through systemd docs.

David
