From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Sun, 15 Nov 2015 10:01:09 +0100
Message-ID: <20151115090109.GA2193@nanopsycho.orion>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
 <20151114093920.GA2188@nanopsycho.orion>
 <56481D60.10209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Premkumar Jonnala <pjonnala@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, andrew@lunn.ch,
	f.fainelli@gmail.com, idosch@mellanox.com,
	nikolay@cumulusnetworks.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36690 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbbKOJBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 04:01:12 -0500
Received: by wmww144 with SMTP id w144so75596785wmw.1
        for <netdev@vger.kernel.org>; Sun, 15 Nov 2015 01:01:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56481D60.10209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Nov 15, 2015 at 06:51:28AM CET, john.fastabend@gmail.com wrote:
>On 15-11-14 01:39 AM, Jiri Pirko wrote:
>> Thu, Nov 12, 2015 at 05:02:18PM CET, pjonnala@broadcom.com wrote:
>>> Packet forwarding to/from bond interfaces is done in software.
>>>
>>> This patch enables certain platforms to bridge traffic to/from
>>> bond interfaces in hardware.  Notifications are sent out when 
>>> the "active" slave set for a bond interface is updated in 
>>> software.  Platforms use the notifications to program the 
>>> hardware accordingly.  The changes have been verified to work 
>>> with configured and 802.3ad bond interfaces.
>>>
>>> Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>
>> 
>> This patch is wrong, in many different acpects. Leaving the submission
>> style, and no in-tree consumer aside, adding ndos for this thing is
>> unacceptable. It should be handled as a part of switchdev attrs.
>
>Why is it unacceptable? I think its at least worth debating. If I
>have a nic that can do bonding but none of the other switchdev
>things then implementing another ndo is certainly more straight
>forward. As it is heading many of the 10+Gbps nics may need to
>implement just enough of the switchdev infrastructure to get things
>like bonding up and working. Not necessarily a bad thing if we make
>the switchdev infrastructure light but does sort of make the name
>confusing if my nic is not doing any switching ;)

Can you please describe what exaclty such a NIC functionality would look
like? If there's not switching/forwarding, then the packets would go
trought slow-path (kernel bonding/team driver). So why would we need to
tell anything to driver/hw?

Thanks.
