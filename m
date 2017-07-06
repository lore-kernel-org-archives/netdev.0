From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] ip[6]: don't register inet[6]dev when dev is down
Date: Thu, 6 Jul 2017 14:08:08 +0200
Message-ID: <7238f160-2547-c51a-c8fe-bcbc5d774239@6wind.com>
References: <20170705155725.15469-1-nicolas.dichtel@6wind.com>
 <CAM_iQpUtniWmKAOGnjJ+d-cWeQkgEPhcwKFdMeVy49rCe2Sh5g@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Hongjun Li <hongjun.li@6wind.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:35213 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751900AbdGFMIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 08:08:13 -0400
Received: by mail-wr0-f179.google.com with SMTP id k67so88499wrc.2
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 05:08:13 -0700 (PDT)
In-Reply-To: <CAM_iQpUtniWmKAOGnjJ+d-cWeQkgEPhcwKFdMeVy49rCe2Sh5g@mail.gmail.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/07/2017 à 00:43, Cong Wang a écrit :
> On Wed, Jul 5, 2017 at 8:57 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> When a device changes from one netns to another, it's first unregistered,
>> then the netns reference is updated and the dev is registered in the new
>> netns. Thus, when a slave moves to another netns, it is first
>> unregistered. This triggers a NETDEV_UNREGISTER event which is caught by
>> the bonding driver. The driver calls bond_release(), which calls
>> dev_set_mtu() and thus triggers NETDEV_CHANGEMTU (the device is still in
>> the old netns).
> 
> I think in this special case it is meaningless to send
> NETDEV_CHANGEMTU, because the device is dying within
> its old netns, who still cares about its mtu change?
> 
> Something like the attached patch...
Yes, your patch seems good and I hesitated with something like this.
But I don't see a valid case where the inet[6]dev must be created on a down
interface. I think the patch is valid, even with your patch.


Regards,
Nicolas
