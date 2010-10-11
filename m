From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH] net/fec: carrier off initially to avoid root mount failure
Date: Mon, 11 Oct 2010 22:38:47 +1000
Message-ID: <4CB30557.4020005@snapgear.com>
References: <1286454630-7396-1-git-send-email-oskar@linutronix.de> <20101010.211956.112597497.davem@davemloft.net> <20101011075420.GA17320@www.tglx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dan@embeddedalley.com, bigeasy@linutronix.de, hjk@linutronix.de,
	gerg@uclinux.org, bhutchings@solarflare.com
To: Oskar Schirmer <oskar@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dalsmrelay2.nai.com ([205.227.136.216]:42585 "HELO
	dalsmrelay2.nai.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752888Ab0JKMjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 08:39:13 -0400
In-Reply-To: <20101011075420.GA17320@www.tglx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/10 17:54, Oskar Schirmer wrote:
> On Sun, Oct 10, 2010 at 21:19:56 -0700, David Miller wrote:
>> From: Oskar Schirmer<oskar@linutronix.de>
>> Date: Thu,  7 Oct 2010 14:30:30 +0200
>>
>>> with hardware slow in negotiation, the system did freeze
>>> while trying to mount root on nfs at boot time.
>>>
>>> the link state has not been initialised so network stack
>>> tried to start transmission right away. this caused instant
>>> retries, as the driver solely stated business upon link down,
>>> rendering the system unusable.
>>>
>>> notify carrier off initially to prevent transmission until
>>> phylib will report link up.
>>>
>>> Signed-off-by: Oskar Schirmer<oskar@linutronix.de>
>>
>> I did some more investigation into this situation, and for now I'm
>> going to apply your patch.  It is correct, and it also matches what
>> the only other seemingly correct driver I could find using phylib does
>> (gianfar) :-) Actually, although I didn't check, bi-modal drivers
>> (those that only use phylib for some phy types) like tg3 probably do
>> the right thing here too.
>>
>> Longer term I think the right thing to do might be:
>>
>> 1) Create some notion of "network device has managed carrier"
>>
>>     This could simply be a flag bit in the netdev or netdev_ops,
>>     or some other kind of attribute.
>>
>> 2) Managed carrier devices start with netif_carrier_off(), otherwise
>>     the device starts with netif_carrier_on().
>
> This last conditional (managed vs otherwise) would be implicit
> with a null PHY driver as Ben Hutchings proposes it to Greg Ungerers
> "allow FEC driver to not have attached PHY", 2010/10/07,
> with the null PHY simply switching to netif_carrier_on right after
> machine start.
>
> Otherwise my patch would need another #ifdef to live in
> peace with Gregs patch.

You can ignore my patch for now. I am reworking the it to
use fixed phy. It will look quite different when it is done.

Regards
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close,                            FAX:         +61 7 3891 3630
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com
