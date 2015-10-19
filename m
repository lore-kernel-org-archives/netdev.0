From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v8 net-next 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Mon, 19 Oct 2015 11:01:24 -0700
Message-ID: <CAF2d9jhJzyH8iaXJJY81PQTCx1BeB2x16a0HBYbboQoLmsFY9Q@mail.gmail.com>
References: <1412469901-27451-1-git-send-email-maheshb@google.com> <20151019163556.GK2288@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:33905 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbbJSSBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 14:01:44 -0400
Received: by ykfy204 with SMTP id y204so150660696ykf.1
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 11:01:44 -0700 (PDT)
In-Reply-To: <20151019163556.GK2288@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2015 at 9:35 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Sun, Oct 05, 2014 at 02:45:01AM CEST, maheshb@google.com wrote:
>>Earlier change to use usable slave array for TLB mode had an additional
>>performance advantage. So extending the same logic to all other modes
>>that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
>>Also consolidating this with the earlier TLB change.
>>
>>The main idea is to build the usable slaves array in the control path
>>and use that array for slave selection during xmit operation.
>>
>>Measured performance in a setup with a bond of 4x1G NICs with 200
>>instances of netperf for the modes involved (3ad, xor, tlb)
>>cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5
>>
>>Mode        TPS-Before   TPS-After
>>
>>802.3ad   : 468,694      493,101
>>TLB (lb=0): 392,583      392,965
>>XOR       : 475,696      484,517
>
> Looking over bonding code now and came across this commit. It gave me a
> little headache. Why don't you guys just use team instead of doing
> bonding megapatches like this? This is making bonding code even more
> complicated (screwed-up) :/ I don't understand.

Why are you looking at bonding to have headache in first place go use team. ;)

The commit message was very clear about the intention and the purpose
is to avoid list-traversal cost in fast path for modes that use
xmit-hash. If you feel something is screwed-up please send a patch to
fix it.
