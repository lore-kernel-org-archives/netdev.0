From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Mon, 7 Feb 2011 18:24:45 -0800
Message-ID: <AANLkTinJ3ga46FfvPJCnxSH129mSC2TCdPRSXwu+iiJo@mail.gmail.com>
References: <4D32FC1C.3010905@simon.arlott.org.uk>
	<201101231845.20505.maciej.rutecki@gmail.com>
	<AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com>
	<201101241625.45367.maciej.rutecki@gmail.com>
	<loom.20110205T163216-459@post.gmane.org>
	<AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com>
	<loom.20110206T203347-475@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: chriss <mail_to_chriss@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64758 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779Ab1BHCYq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 21:24:46 -0500
Received: by iyj8 with SMTP id 8so2821368iyj.19
        for <netdev@vger.kernel.org>; Mon, 07 Feb 2011 18:24:45 -0800 (PST)
In-Reply-To: <loom.20110206T203347-475@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 6, 2011 at 11:37 AM, chriss <mail_to_chriss@gmx.net> wrote:
> Jesse Gross <jesse <at> nicira.com> writes:
>
>>
>> You should either attached a bridge to a vlan device or stack a vlan
>> device on the bridge port depending on what you are trying to achiev=
e.
>>
>> The bridge handler takes all packets of the device that it is attach=
ed
>> to, so having a vlan also attached to the same device will not work.
>> You may get different results on older kernels depending on what NIC
>> you were using but that was a bug.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo <at> vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>>
>
>
> Hi and thanks for your reply
>
> I tried that.
>
> I had under 2.6.36.3 following combination:
>
> eth1 in br0 -> all traffic without vlan id
> eth1.3 -> traffic with vlan 3
>
> with 2.6.37 i should do the following
> eth1 in br0 -> traffic w/o vlans
> and br0.3 -> traffic with vlan id 3
>
> But still there is no rx for vlan 3.
> Any suggestions? Or am i missing something?

That configuration should work (and I've tested it in the past).  I
would try running tcpdump on the various interfaces in the path (eth1,
br0, br0.3) to see where traffic is flowing or not.
