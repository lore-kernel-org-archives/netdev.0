From: Kalle Valo <kvalo@adurom.com>
Subject: Re: A race in register_netdevice()
Date: Fri, 29 Apr 2011 20:20:41 +0300
Message-ID: <87tydhgeja.fsf@purkki.adurom.net>
References: <87y62ugg0a.fsf@purkki.adurom.net>
	<20110428165237.0c1eddbc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from purkki.adurom.net ([80.68.90.206]:44547 "EHLO purkki.adurom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757894Ab1D2RUn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2011 13:20:43 -0400
In-Reply-To: <20110428165237.0c1eddbc@nehalam> (Stephen Hemminger's message of "Thu\, 28 Apr 2011 16\:52\:37 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Fri, 29 Apr 2011 01:36:37 +0300
>
>> there seems to be a race in register_netdevice(), which is reported here:
>> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=15606
>> 
>> This is visible at least with flimflam and ath6kl. Basically what
>> happens is this:
>> 
>> Apr 29 00:21:35 roska flimflamd[2598]: src/udev.c:add_net_device() 
>> Apr 29 00:21:35 roska flimflamd[2598]: connman_inet_ifname: SIOCGIFNAME(index
>> 4): No such device
>> Apr 29 00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message() buf
>> 0xbfefda3c len 1004
>> Apr 29 00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message()
>> NEWLINK len 1004 type 16 flags 0x0000 seq 0

[...]

>> I have confirmed that both of these patches fix the issue. Now I'm
>> wondering which one is the best way forward. Or is there a better way
>> to fix this?
>> 
>
> I see no problem with moving this.
> SIOCGIFNAME should not need to hold rtnl.

Ok, thanks for comments. I'll send a proper patch.

-- 
Kalle Valo
