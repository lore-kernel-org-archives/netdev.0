From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v8 net-next 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Mon, 19 Oct 2015 20:07:18 +0200
Message-ID: <20151019180718.GA10106@nanopsycho.orion>
References: <1412469901-27451-1-git-send-email-maheshb@google.com>
 <20151019163556.GK2288@nanopsycho.orion>
 <CAF2d9jhJzyH8iaXJJY81PQTCx1BeB2x16a0HBYbboQoLmsFY9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:32908 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbbJSSHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 14:07:21 -0400
Received: by lffv3 with SMTP id v3so117045250lff.0
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 11:07:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAF2d9jhJzyH8iaXJJY81PQTCx1BeB2x16a0HBYbboQoLmsFY9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 19, 2015 at 08:01:24PM CEST, maheshb@google.com wrote:
>On Mon, Oct 19, 2015 at 9:35 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Sun, Oct 05, 2014 at 02:45:01AM CEST, maheshb@google.com wrote:
>>>Earlier change to use usable slave array for TLB mode had an additional
>>>performance advantage. So extending the same logic to all other modes
>>>that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
>>>Also consolidating this with the earlier TLB change.
>>>
>>>The main idea is to build the usable slaves array in the control path
>>>and use that array for slave selection during xmit operation.
>>>
>>>Measured performance in a setup with a bond of 4x1G NICs with 200
>>>instances of netperf for the modes involved (3ad, xor, tlb)
>>>cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5
>>>
>>>Mode        TPS-Before   TPS-After
>>>
>>>802.3ad   : 468,694      493,101
>>>TLB (lb=0): 392,583      392,965
>>>XOR       : 475,696      484,517
>>
>> Looking over bonding code now and came across this commit. It gave me a
>> little headache. Why don't you guys just use team instead of doing
>> bonding megapatches like this? This is making bonding code even more
>> complicated (screwed-up) :/ I don't understand.
>
>Why are you looking at bonding to have headache in first place go use team. ;)
>
>The commit message was very clear about the intention and the purpose
>is to avoid list-traversal cost in fast path for modes that use
>xmit-hash. If you feel something is screwed-up please send a patch to
>fix it.

No, it's about the concept. You introduced something in bonding which
team already has and made the code even more complicated and scary.
I just don't understand why you didn't use team instead of this :/
Just my 50 cents.
