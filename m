From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net] Revert "ipv6: ndisc: inherit metadata dst when
 creating ndisc requests"
Date: Tue, 1 Dec 2015 14:20:35 +0100
Message-ID: <565D9EA3.3040105@6wind.com>
References: <1448644625-29345-1-git-send-email-nicolas.dichtel@6wind.com>
 <20151130122038.26c5de6b@griffin>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33583 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877AbbLANUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:20:54 -0500
Received: by wmec201 with SMTP id c201so204945261wme.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:20:53 -0800 (PST)
In-Reply-To: <20151130122038.26c5de6b@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/11/2015 12:20, Jiri Benc a =E9crit :
> On Fri, 27 Nov 2015 18:17:05 +0100, Nicolas Dichtel wrote:
>> This reverts commit ab450605b35caa768ca33e86db9403229bf42be4.
>>
>> In IPv6, we cannot inherit the dst of the original dst. ndisc packet=
s
>> are IPv6 packets and may take another route than the original packet=
=2E
>>
>> This patch breaks the following scenario: a packet comes from eth0 a=
nd
>> is forwarded through vxlan1. The encapsulated packet triggers an NS
>> which cannot be sent because of the wrong route.
>>
>> CC: Jiri Benc <jbenc@redhat.com>
>> CC: Thomas Graf <tgraf@suug.ch>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>
>> I know that this is not the right fix, it's why I've put RFC ;-)
>
> I'm actually okay with applying the revert for now. The revert is not
> the right fix but at least it is less wrong than the current state.
Ok for me.

>
> The problem is deeper. I fixed the IPv4 part in commit 63d008a4e9ee
> ("ipv4: send arp replies to the correct tunnel") but for IPv6, I don'=
t
> know how to fix it. We already have dst set for IPv6, thus we cannot
> use it to carry lwtunnel metadata for ndisc replies.
I will also think a bit more to this.

>
> I tried to consult this with a couple of people, haven't met with muc=
h
> interest.
>
>> Should the right fix only do a copy of dst metadata in the new dst?
>
> Copy of the dst (I'm afraid we cannot just set the ->lwtstate field,
> the same dst_entry may be shared between different tunnels) is pretty
> much the only thing I could think of.
Yes, you're right.


Thank you,
Nicolas
