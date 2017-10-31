From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 1/9] net_sch: red: Add offload ability to
 RED qdisc
Date: Tue, 31 Oct 2017 08:41:51 +0100
Message-ID: <20171031074151.GD1972@nanopsycho.orion>
References: <20171030085613.8697-1-jiri@resnulli.us>
 <20171030085613.8697-2-jiri@resnulli.us>
 <20171030.212015.742241045938302800.davem@davemloft.net>
 <DB5PR05MB18954A4B8E0C9F9300F3EE59AC590@DB5PR05MB1895.eurprd05.prod.outlook.com>
 <c02f7bb1-b534-64fb-8beb-d5f379773fab@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:48810 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752174AbdJaHlx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 03:41:53 -0400
Received: by mail-wr0-f195.google.com with SMTP id 15so15015650wrb.5
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 00:41:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <c02f7bb1-b534-64fb-8beb-d5f379773fab@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 30, 2017 at 08:24:20PM CET, dsahern@gmail.com wrote:
>On 10/30/17 7:54 AM, Nogah Frankel wrote:
>>>> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
>>>> index 0e88cc2..743c42a 100644
>>>> --- a/include/uapi/linux/pkt_sched.h
>>>> +++ b/include/uapi/linux/pkt_sched.h
>>>> @@ -255,6 +255,7 @@ struct tc_red_qopt {
>>>>  #define TC_RED_ECN		1
>>>>  #define TC_RED_HARDDROP		2
>>>>  #define TC_RED_ADAPTATIVE	4
>>>> +#define TC_RED_OFFLOADED	8
>>>>  };
>>>>
>>>>  struct tc_red_xstats {
>>>
>>> What keeps a user from setting this flag in the tc_red_qopt it
>>> passes into the a change operation?
>> 
>> Nothing keeps the user from doing it, but it has no effect.
>> The decision to offload is the driver's only.
>> It is basically a read-only flag.
>> 
>
>If it is read-only, then attempts to set it from userspace should cause
>the command to fail.

That breaks uapi. Consider existing userspace app sending garbage in
that bit and new kernel which randomly fails upon the garbage.
