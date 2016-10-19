From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Wed, 19 Oct 2016 13:07:00 -0700
Message-ID: <CAM_iQpU8XPixg3g=NPbOcUPDu+o1bOccpnng=HrW8-VzY-xmgw@mail.gmail.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com>
 <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com> <CAA1AmC2KiuoDiuBmjFAS20UnzkfCCnvHYyXhm3MOrVBUty9EeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Ido Schimmel <idosch@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>
To: Elad Raz <e@eladraz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34964 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942476AbcJSUHV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 16:07:21 -0400
Received: by mail-it0-f67.google.com with SMTP id 139so2469937itm.2
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 13:07:21 -0700 (PDT)
In-Reply-To: <CAA1AmC2KiuoDiuBmjFAS20UnzkfCCnvHYyXhm3MOrVBUty9EeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2016 at 8:21 AM, Elad Raz <e@eladraz.com> wrote:
> On Fri, Sep 2, 2016 at 11:12 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> Le 02/09/2016 =C3=A0 06:53, Cong Wang a =C3=A9crit :
>>> We never read or change netns id in hardirq context,
>>> the only place we read netns id in softirq context
>>> is in vxlan_xmit(). So, it should be enough to just
>>> disable BH.
>>
>> Are you sure? Did you audit all part of the code?
>> peernet2id() is called from netlink core system (do_one_broadcast()). Ar=
e you
>> sure that no driver call this function from an hard irq context?
>>
>> I think that NETLINK_LISTEN_ALL_NSID is largely untested, so it will be =
hard to
>> detect a bug introduced in this feature.
>
> I'm seeing strange things on our systems on boot time when trying to
> mount autofs.
> I bisected and got this patch as the bad one.
> I can see that only when I'm using "debug" config file.

Yeah, I saw the same report from SELinux developers, I am working
on a fix.

Thanks.
