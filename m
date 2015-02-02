From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: rocker: Change netdev names to include slot number
Date: Mon, 02 Feb 2015 14:03:12 -0800
Message-ID: <54CFF420.3090603@gmail.com>
References: <1422856985-16530-1-git-send-email-dsahern@gmail.com> <CAE4R7bA0Ea9zugm=OR0EN2qSeoiROEoMiYZ-5YMwd9UdS4L0Sg@mail.gmail.com> <54CFEF20.8060300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:38043 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965207AbbBBWDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 17:03:20 -0500
Received: by mail-pa0-f50.google.com with SMTP id rd3so87511038pab.9
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 14:03:19 -0800 (PST)
In-Reply-To: <54CFEF20.8060300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/15 13:41, David Ahern wrote:
> On 2/2/15 2:33 PM, Scott Feldman wrote:
>> On Sun, Feb 1, 2015 at 10:03 PM, David Ahern <dsahern@gmail.com> wrote:
>>> Currently, rocker devices are given eth%d names. If you have multiple
>>> rocker devices it is difficult to easily correlate eth%d names to a
>>> rocker device and port. Change the device name to sw + PCI slot
>>> number + p + id (sw%dp%d). This makes the device names easier to
>>> correlate. ie., Rather than eth0, ..., eth N (N = number of ports in
>>> device) the ports get netdev names like sw5p0, ..., sw5pN.
>>
>> I think udev is the preferred tool for interface naming, rather than
>> hard-coding interface names in the driver.
>>
> 
> 
> hmmm...  What I am seeing right now is a race as to which devices are
> detected first -- rocker or virtio. On half of the boots the virtio are
> detected first and named eth0 and eth1. The other half of the boots
> virtio devices are detected last and become ethN+1 and ethN+2 (N=number
> of rocker ports) -- which makes it a PITA to script commands. AFAIK udev
> won't solve that problem.

Why not? virtio and rocker interfaces are backed by different devices
drivers which should allow you to use that to name interfaces
differently. In the case of rocker, you would probably want to read the
phys_port_id sysfs attribute to name them after their parent switch id too.

> 
> David
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Florian
