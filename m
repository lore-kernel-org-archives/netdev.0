From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict synchronization of
 link_up and speed
Date: Wed, 30 Dec 2015 11:06:54 +0800
Message-ID: <56834A4E.2090007@gmail.com>
References: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
 <1451356326-2919-1-git-send-email-zyjzyj2000@gmail.com>
 <1451356326-2919-3-git-send-email-zyjzyj2000@gmail.com>
 <87618083B2453E4A8714035B62D67992504FB5FF@FMSMSX105.amr.corp.intel.com>
 <53C6554C-8692-4EF3-BF5D-7217D2C9FDA0@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Viswanathan, Ven (Wind River)" <venkat.viswanathan@windriver.com>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>,
	"Bourg, Vincent (Wind River)" <vincent.bourg@windriver.com>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34856 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127AbbL3DHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 22:07:08 -0500
Received: by mail-pf0-f173.google.com with SMTP id 78so135330269pfw.2
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 19:07:08 -0800 (PST)
In-Reply-To: <53C6554C-8692-4EF3-BF5D-7217D2C9FDA0@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2015 03:17 AM, Rustad, Mark D wrote:
> Emil S <emil.s.tantilov@intel.com> wrote:
>
>>>   */
>>> -	if (hw->mac.type == ixgbe_mac_X540)
>>> +	if ((hw->mac.type == ixgbe_mac_X540) &&
>>> +	    (netdev->flags & IFF_SLAVE))
>>> 		if (link_speed == IXGBE_LINK_SPEED_UNKNOWN)
>>> 			return;
>> If you were to enter ixgbe_watchdog_link_is_up() with unknown speed, then I would
>> assume that you also have a dmesg that shows:
>> "NIC Link is Up unknown speed"
>>
>> by the interface you use in the bond?
> It seems odd to be checking the MAC type for this. Is this behavior perhaps more related to the copper phy? If so, then the check should be changed. Or would the check for unknown link speed be sufficient? It seems like an interface as a slave would not work with an unknown link speed, so it may as well wait in all cases, not just for X540.
>
> --
> Mark Rustad, Networking Division, Intel Corporation
Hi, Mark

Thanks for your suggestions.
The following is the feedback from the customer.
"
...
We observing this issue on x540T interfaces (8086:1528), but not on 
82599_SFP (8086:10FB).
...
"
To narrow this problem, I restrict mac.type to ixgbe_mac_X540. I agree 
with you. Maybe this problem is
related with the copper phy. But I only have X540 NIC to test. So it is 
difficult for me to confirm whether this
problem occurs on other mac type or not, such as X550.

I will consider your suggestions in the latest patch.

Thanks again.

Zhu Yanjun
