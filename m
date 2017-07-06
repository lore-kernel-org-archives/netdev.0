From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ip[6]: don't register inet[6]dev when dev is down
Date: Thu, 6 Jul 2017 11:16:43 -0700
Message-ID: <CAM_iQpXMR6RmJX52=7qrGVKopvGCiabS2sUOCf2Dvjhe4wLAzA@mail.gmail.com>
References: <20170705155725.15469-1-nicolas.dichtel@6wind.com>
 <CAM_iQpUtniWmKAOGnjJ+d-cWeQkgEPhcwKFdMeVy49rCe2Sh5g@mail.gmail.com> <7238f160-2547-c51a-c8fe-bcbc5d774239@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Hongjun Li <hongjun.li@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:34523 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751874AbdGFSRF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 14:17:05 -0400
Received: by mail-wr0-f176.google.com with SMTP id 77so13838230wrb.1
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 11:17:05 -0700 (PDT)
In-Reply-To: <7238f160-2547-c51a-c8fe-bcbc5d774239@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 6, 2017 at 5:08 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 06/07/2017 =C3=A0 00:43, Cong Wang a =C3=A9crit :
>> On Wed, Jul 5, 2017 at 8:57 AM, Nicolas Dichtel
>> <nicolas.dichtel@6wind.com> wrote:
>>> When a device changes from one netns to another, it's first unregistere=
d,
>>> then the netns reference is updated and the dev is registered in the ne=
w
>>> netns. Thus, when a slave moves to another netns, it is first
>>> unregistered. This triggers a NETDEV_UNREGISTER event which is caught b=
y
>>> the bonding driver. The driver calls bond_release(), which calls
>>> dev_set_mtu() and thus triggers NETDEV_CHANGEMTU (the device is still i=
n
>>> the old netns).
>>
>> I think in this special case it is meaningless to send
>> NETDEV_CHANGEMTU, because the device is dying within
>> its old netns, who still cares about its mtu change?
>>
>> Something like the attached patch...
> Yes, your patch seems good and I hesitated with something like this.
> But I don't see a valid case where the inet[6]dev must be created on a do=
wn
> interface. I think the patch is valid, even with your patch.

Your patch is more risky because it affects normal CHANGEMTU path,
I am not sure if it is correct to not to add idev when it is down either.

This is a very unusual path, we don't have to take the risk.
