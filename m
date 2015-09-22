From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] net: Handle negative checksum offset in skb-checksum-help
Date: Mon, 21 Sep 2015 19:49:17 -0700
Message-ID: <CALnjE+r+He=cyPnJO9qqqKyu0K9awrEgNeBefumqp1wDN=JbWw@mail.gmail.com>
References: <1442818397-2210-1-git-send-email-pshelar@nicira.com>
	<20150921.171412.613695619204829336.davem@davemloft.net>
	<CALnjE+owCFib4oXD5zbJNRR9ZosT508tS=0_YL3UD1xg51hD3g@mail.gmail.com>
	<1442888056.29850.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36564 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345AbbIVCtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 22:49:18 -0400
Received: by ioii196 with SMTP id i196so3446657ioi.3
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 19:49:17 -0700 (PDT)
In-Reply-To: <1442888056.29850.70.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 7:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2015-09-21 at 18:04 -0700, Pravin Shelar wrote:
>> On Mon, Sep 21, 2015 at 5:14 PM, David Miller <davem@davemloft.net> wrote:
>> > From: Pravin B Shelar <pshelar@nicira.com>
>> > Date: Sun, 20 Sep 2015 23:53:17 -0700
>> >
>> >> VXLAN device can receive skb with checksum partial. But the checksum
>> >> offset could be in outer header which is pulled on receive.
>> >
>> > Such a scenerio is a bug.
>> >
>> > Anything that pulls off a header should use a utility function such
>> > as skb_pull_rcsum() or skb_postpull_rcsum() to make sure this gets
>> > fixed up properly.
>>
>> skb_postpull_rcsum() does not change checksum-offset. vxlan receive
>> already calls this function.
>
> Then the bug is here.
>
> Otherwise we might have to 'fix' other places.
>
I posted a patch to fix skb_postpull_rcsum() to handle this case. But
that was not accepted.
https://patchwork.ozlabs.org/patch/512625/

And specific solution for skb_checksum_help() was suggested.

http://marc.info/?l=linux-netdev&m=144108078931774&w=2
