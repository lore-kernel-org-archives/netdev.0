From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH net-next v2] bridge: also trigger RTM_NEWLINK when interface is released from bridge
Date: Thu, 21 Sep 2017 17:31:32 +0200
Message-ID: <87vakc3w6j.fsf@luffy.cx>
References: <m3zi9vbrfp.fsf@luffy.cx>
        <20170916141833.28344-1-vincent@bernat.im>
        <20170920.140956.781667692297467325.davem@davemloft.net>
        <16e5566a-909d-ba83-7637-1fb6c93126bc@gmail.com>
        <20170920162140.369bb198@xeon-e3> <87h8vw5pwg.fsf@luffy.cx>
        <CAJieiUgKO-O3YFc3iTQXMmXc287RGgw4FjYhaLn-7+pmA_Fh+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        David Ahern <dsahern@gmail.com>,
        David Miller <davem@davemloft.net>,
        bridge@lists.linux-foundation.org,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:60935 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751811AbdIUPbe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 11:31:34 -0400
In-Reply-To: <CAJieiUgKO-O3YFc3iTQXMmXc287RGgw4FjYhaLn-7+pmA_Fh+g@mail.gmail.com>
        (Roopa Prabhu's message of "Thu, 21 Sep 2017 08:09:28 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 21 septembre 2017 08:09 -0700, Roopa Prabhu <roopa@cumulusnetwor=
ks.com>=C2=A0:

>>> The one concern is that ports added or removed through ioctl should
>>> cause same events as doing the same thing via netlink. Some users use
>>> brctl (ioctl) and others use newer bridge (netlink) API.
>>
>> I'll make a third iteration to have the same notifications when using
>> ioctl() with details in the commit message.
>> --
>
> as long as the ioctl path for bridge port removal is generating a:
> RTM_DELLINK with AF_BRIDGE and
> RTM_NEWLINK with AF_UNSPEC with 'master' removed
>
> we should be good. These are the most important ones.
>
> are there other specific bridge-events missing ?. you might want to
> run `bridge monitor link` also. and un-slaving of a port also triggers
> fdb events which are visible under `bridge monitor fdb`

With the patch, bridge monitor link generates the same event with
ioctl() than with netlink (like for ip monitor link, netlink generates
one extra duplicate event when enslaving).

For bridge monitor fdb, there is a difference. With ioctl(), I don't get
the event for VLAN1:

Deleted ca:18:06:bc:f6:11 dev dummy1 vlan 1 master bridge0 permanent

I suppose this is an expected difference due to the inability to manage
VLAN-aware bridges with ioctl().
--=20
Use the fundamental control flow constructs.
            - The Elements of Programming Style (Kernighan & Plauger)
