From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2 00/10] Low-level Ethernet debugging features.
Date: Fri, 10 Feb 2012 09:18:59 -0800
Message-ID: <4F355183.2060704@candelatech.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com>  <4F349DB0.1010903@gmail.com> <4F34AE62.6070409@candelatech.com> <1328880345.2443.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, Jeff Kirsher <tarbal@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57336 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758243Ab2BJRTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 12:19:02 -0500
In-Reply-To: <1328880345.2443.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2012 05:25 AM, Eric Dumazet wrote:
> Le jeudi 09 f=C3=A9vrier 2012 =C3=A0 21:42 -0800, Ben Greear a =C3=A9=
crit :
>> On 02/09/2012 08:31 PM, Jeff Kirsher wrote:
>>
>>> Thanks Ben!
>>>
>>> I have applied the series of 10 patches to my queue.  I would like =
to
>>> have our validation team validate the e100, e1000 and e1000e patche=
s
>>> (and in-directly the net patches).
>>
>> Just in case you can generate errored frames other than ones with ju=
st
>> bad FCS, I'm curious to know if rx-all logic works with them.
>>
>> I was thinking I might could get at least some NICs to generate Runt=
 frames
>> by sending small pkts and disabling frame padding, but haven't looke=
d into
>> it too hard yet.
>
> I am interested by this, do you know some NICs able to disable frame
> padding ?

It looks like e1000e driver can send frames at down to 32 bytes, which
should be considered a runt.  I think we'd just need to disable any
padding in the software stacks (not sure it's there now or not), and th=
en
twiddle the 'PSP' but in the "Transmit Control Register".

I'm not sure the best way to enable this feature up at user-space level=
,
but we could piggy-back on the no-fcs socket option and extend that
flag to mean don't pad packets as well.

Or, could add a new sock-opt perhaps.

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
