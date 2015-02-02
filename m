From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: rocker: Change netdev names to include slot number
Date: Mon, 02 Feb 2015 14:41:52 -0700
Message-ID: <54CFEF20.8060300@gmail.com>
References: <1422856985-16530-1-git-send-email-dsahern@gmail.com> <CAE4R7bA0Ea9zugm=OR0EN2qSeoiROEoMiYZ-5YMwd9UdS4L0Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:56975 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbBBVlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 16:41:53 -0500
Received: by mail-ie0-f171.google.com with SMTP id tr6so20685927ieb.2
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 13:41:53 -0800 (PST)
In-Reply-To: <CAE4R7bA0Ea9zugm=OR0EN2qSeoiROEoMiYZ-5YMwd9UdS4L0Sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/2/15 2:33 PM, Scott Feldman wrote:
> On Sun, Feb 1, 2015 at 10:03 PM, David Ahern <dsahern@gmail.com> wrote:
>> Currently, rocker devices are given eth%d names. If you have multiple
>> rocker devices it is difficult to easily correlate eth%d names to a
>> rocker device and port. Change the device name to sw + PCI slot
>> number + p + id (sw%dp%d). This makes the device names easier to
>> correlate. ie., Rather than eth0, ..., eth N (N = number of ports in
>> device) the ports get netdev names like sw5p0, ..., sw5pN.
>
> I think udev is the preferred tool for interface naming, rather than
> hard-coding interface names in the driver.
>


hmmm...  What I am seeing right now is a race as to which devices are 
detected first -- rocker or virtio. On half of the boots the virtio are 
detected first and named eth0 and eth1. The other half of the boots 
virtio devices are detected last and become ethN+1 and ethN+2 (N=number 
of rocker ports) -- which makes it a PITA to script commands. AFAIK udev 
won't solve that problem.

David
