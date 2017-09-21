From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: also trigger RTM_NEWLINK when
 interface is released from bridge
Date: Thu, 21 Sep 2017 08:09:28 -0700
Message-ID: <CAJieiUgKO-O3YFc3iTQXMmXc287RGgw4FjYhaLn-7+pmA_Fh+g@mail.gmail.com>
References: <m3zi9vbrfp.fsf@luffy.cx> <20170916141833.28344-1-vincent@bernat.im>
 <20170920.140956.781667692297467325.davem@davemloft.net> <16e5566a-909d-ba83-7637-1fb6c93126bc@gmail.com>
 <20170920162140.369bb198@xeon-e3> <87h8vw5pwg.fsf@luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        David Ahern <dsahern@gmail.com>,
        David Miller <davem@davemloft.net>,
        bridge@lists.linux-foundation.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:43989 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751711AbdIUPJa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 11:09:30 -0400
Received: by mail-ua0-f182.google.com with SMTP id f44so1902778uaa.0
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 08:09:30 -0700 (PDT)
In-Reply-To: <87h8vw5pwg.fsf@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 3:04 AM, Vincent Bernat <vincent@bernat.im> wrote:
>  =E2=9D=A6 20 septembre 2017 16:21 -0700, Stephen Hemminger <stephen@netw=
orkplumber.org> :
>
>> The one concern is that ports added or removed through ioctl should
>> cause same events as doing the same thing via netlink. Some users use
>> brctl (ioctl) and others use newer bridge (netlink) API.
>
> I'll make a third iteration to have the same notifications when using
> ioctl() with details in the commit message.
> --

as long as the ioctl path for bridge port removal is generating a:
RTM_DELLINK with AF_BRIDGE and
RTM_NEWLINK with AF_UNSPEC with 'master' removed

we should be good. These are the most important ones.

are there other specific bridge-events missing ?. you might want to
run `bridge monitor link` also. and un-slaving of a port also triggers
fdb events which are visible under `bridge monitor fdb`
