From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH] net: rocker: Change netdev names to include slot number
Date: Mon, 2 Feb 2015 21:46:23 -0800
Message-ID: <CAE4R7bArt7+C-kHJ7UXFo4w9feG0C_uZqQ7n8KC0brSXhqX3gg@mail.gmail.com>
References: <1422856985-16530-1-git-send-email-dsahern@gmail.com>
	<CAE4R7bA0Ea9zugm=OR0EN2qSeoiROEoMiYZ-5YMwd9UdS4L0Sg@mail.gmail.com>
	<54CFEF20.8060300@gmail.com>
	<54CFF420.3090603@gmail.com>
	<54CFF5B3.7070509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:46037 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbbBCFqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 00:46:25 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so21594398wiv.0
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 21:46:24 -0800 (PST)
In-Reply-To: <54CFF5B3.7070509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 2, 2015 at 2:09 PM, David Ahern <dsahern@gmail.com> wrote:
> On 2/2/15 3:03 PM, Florian Fainelli wrote:
>>
>> Why not? virtio and rocker interfaces are backed by different devices
>> drivers which should allow you to use that to name interfaces
>> differently. In the case of rocker, you would probably want to read the
>> phys_port_id sysfs attribute to name them after their parent switch id
>> too.
>
>
> [root@f21 ~]# cat /sys/devices/virtual/net/sw5p0/phys_port_id
> cat: /sys/devices/virtual/net/sw5p0/phys_port_id: Operation not supported

We should implement .ndo_get_phys_port_id in rocker to return a unique
name for the port, which can then be used in udev script to name
interface.  When rocker device is instantiated, a unique switch name
is given on qemu cmd line, for example "sw1".  Rocker device could
return that string to the driver, or even combine that string with the
port index to have "sw1p1".  The second instantiated rocker device
would give up "sw2px" port names.

A real switch with a physical port than can be split, or when multiple
ports are ganged to form one mega port, letting the device pick a
unique name is probably best.  For example, splitting a single
physical 40Gb port into 4 10Gb ports would present 4 kernel
interfaces, but we probably want to use the base port in the naming,
so we'd have something like "sw1p1s1" to mean switch 1, front panel
port 1, split port 1.  Letting the device name the ports on current
port configuration of the port will keep driver/kernel simple, and let
udev be the final name chooser.

>
> But in general I guess need to find time to figure out systemd-udev files.
>
> David
