From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: network status
Date: Wed, 25 Jan 2017 14:05:30 -0800
Message-ID: <CAM_iQpUjkWcHk+3MLiw=xSbRq0MaLKarNZoX2KBcFyTNBZsSiw@mail.gmail.com>
References: <CAH9_wRNWRG0zY20OCXyL_MDci3Bw+RYDjQJCu15+c82C1Eon=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sriram V <vshrirama@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35571 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752409AbdAYWGC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 17:06:02 -0500
Received: by mail-wm0-f41.google.com with SMTP id r126so46910852wmr.0
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 14:05:56 -0800 (PST)
In-Reply-To: <CAH9_wRNWRG0zY20OCXyL_MDci3Bw+RYDjQJCu15+c82C1Eon=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 11:39 AM, Sriram V <vshrirama@gmail.com> wrote:
> Hello,
>
> Apologies in case, this is not the right list of this question.
>
> I wanted to check, How can i find out if a network status has changed
>
> 1. How can the user application find out if the link status has changed?

There are some flags per netdevice for its link status, IFF_LOWER_UP
etc., they are sent to user-space via rtnetlink message, ->ifi_flags.


> 2. what changes do i need to add in the driver to indicate to the user
> applications that ethernet cable has been plugged in or unplugged.
>

Probably nothing but calling netif_carrier_on/off() API's.


> 3. How should a user application know the status change (Should the
> userapp poll on the interface/is there an uevent interface to indicate
> the link status change)
>

It needs to subscribe to the rtnetlink group RTNLGRP_LINK to receive
the broadcasts from kernel.
