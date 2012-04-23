From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Mon, 23 Apr 2012 14:38:07 -0700
Message-ID: <CAEP_g=-52GOr3LzbUB+97ftNQBZV=7NWXqfWN6GMfq5KmdO25A@mail.gmail.com>
References: <CAEP_g=_3om5aR=P0ffa9421KhvYYrMEeE33TNcCC9UV6+XVWAQ@mail.gmail.com>
 <20120423.161313.1582195533832554777.davem@davemloft.net> <CAEP_g=8EVOVgDaWnu3sd+qHxNZ7+ogjzBkuWvfVHNAqX2DRf=g@mail.gmail.com>
 <20120423.170817.1103719420692884446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, horms@verge.net.au, jhs@mojatatu.com,
	stephen.hemminger@vyatta.com, netdev@vger.kernel.org,
	dev@openvswitch.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36872 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755743Ab2DWVi3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 17:38:29 -0400
Received: by lbbgf7 with SMTP id gf7so5981lbb.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 14:38:27 -0700 (PDT)
In-Reply-To: <20120423.170817.1103719420692884446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 23, 2012 at 2:08 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Jesse Gross <jesse@nicira.com>
> Date: Mon, 23 Apr 2012 13:53:42 -0700
>
>> On Mon, Apr 23, 2012 at 1:13 PM, David Miller <davem@davemloft.net> =
wrote:
>>> From: Jesse Gross <jesse@nicira.com>
>>> Date: Mon, 23 Apr 2012 13:08:49 -0700
>>>
>>>> Assuming that the TCP stack generates large TSO frames on transmit
>>>> (which could be the local stack; something sent by a VM; or packet=
s
>>>> received, coalesced by GRO and then encapsulated by STT) then you =
can
>>>> just prepend the STT header (possibly slightly adjusting things li=
ke
>>>> requested MSS, number of segments, etc. slightly). =C2=A0After tha=
t it's
>>>> possible to just output the resulting frame through the IP stack l=
ike
>>>> all tunnels do today.
>>>
>>> Which seems to potentially suggest a stronger intergration of the S=
TT
>>> tunnel transmit path into our IP stack rather than the approach Sim=
on
>>> is taking
>>
>> Did you have something in mind?
>
> A normal bonafide tunnel netdevice driver like GRE instead of the
> openvswitch approach Simon is using.

Ahh, yes, that I agree with.  Independent of this, there's work being
done to make it so that OVS can use the normal in-tree tunneling code
and not need its own.  Once that's done I expect that STT will follow
the same model.
