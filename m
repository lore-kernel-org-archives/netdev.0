From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Sat, 14 Nov 2015 21:51:28 -0800
Message-ID: <56481D60.10209@gmail.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com> <20151114093920.GA2188@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, andrew@lunn.ch,
	f.fainelli@gmail.com, idosch@mellanox.com,
	nikolay@cumulusnetworks.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>,
	Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33095 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbbKOFvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 00:51:49 -0500
Received: by pabfh17 with SMTP id fh17so142097801pab.0
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2015 21:51:49 -0800 (PST)
In-Reply-To: <20151114093920.GA2188@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-11-14 01:39 AM, Jiri Pirko wrote:
> Thu, Nov 12, 2015 at 05:02:18PM CET, pjonnala@broadcom.com wrote:
>> Packet forwarding to/from bond interfaces is done in software.
>>
>> This patch enables certain platforms to bridge traffic to/from
>> bond interfaces in hardware.  Notifications are sent out when 
>> the "active" slave set for a bond interface is updated in 
>> software.  Platforms use the notifications to program the 
>> hardware accordingly.  The changes have been verified to work 
>> with configured and 802.3ad bond interfaces.
>>
>> Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>
> 
> This patch is wrong, in many different acpects. Leaving the submission
> style, and no in-tree consumer aside, adding ndos for this thing is
> unacceptable. It should be handled as a part of switchdev attrs.

Why is it unacceptable? I think its at least worth debating. If I
have a nic that can do bonding but none of the other switchdev
things then implementing another ndo is certainly more straight
forward. As it is heading many of the 10+Gbps nics may need to
implement just enough of the switchdev infrastructure to get things
like bonding up and working. Not necessarily a bad thing if we make
the switchdev infrastructure light but does sort of make the name
confusing if my nic is not doing any switching ;)

Thanks,
John

> Also, the solution should not be bonding-centric.
> 
> I have a patchset in my queue which does this correctly, for bond and team
> using switchdev attr and with actual in-tree consumer, mlxsw driver.
> I plan to send that soon after net-next opens.
> 
> Jiri
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
