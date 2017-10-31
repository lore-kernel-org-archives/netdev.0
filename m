From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next RFC 1/9] net_sch: red: Add offload ability to RED
 qdisc
Date: Tue, 31 Oct 2017 08:59:08 -0600
Message-ID: <5c9e9e0f-a7ae-570a-e052-074511c31967@gmail.com>
References: <20171030085613.8697-1-jiri@resnulli.us>
 <20171030085613.8697-2-jiri@resnulli.us>
 <20171030.212015.742241045938302800.davem@davemloft.net>
 <DB5PR05MB18954A4B8E0C9F9300F3EE59AC590@DB5PR05MB1895.eurprd05.prod.outlook.com>
 <c02f7bb1-b534-64fb-8beb-d5f379773fab@gmail.com>
 <20171031074151.GD1972@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Nogah Frankel <nogahf@mellanox.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        mlxsw <mlxsw@mellanox.com>, "andrew@lunn.ch" <andrew@lunn.ch>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>,
        "simon.horman@netronome.com" <simon.horman@netr
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:55359 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753418AbdJaO71 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 10:59:27 -0400
Received: by mail-pf0-f174.google.com with SMTP id 17so13960288pfn.12
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 07:59:27 -0700 (PDT)
In-Reply-To: <20171031074151.GD1972@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/17 1:41 AM, Jiri Pirko wrote:
>>
>> If it is read-only, then attempts to set it from userspace should cause
>> the command to fail.
> 
> That breaks uapi. Consider existing userspace app sending garbage in
> that bit and new kernel which randomly fails upon the garbage.
> 

It is called syzkaller. The kernel should always validate userspace
config including checking that unused bits are 0. So you are saying tc
has never done that checking and just ignored bits that are not valid?
