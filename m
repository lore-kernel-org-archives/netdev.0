From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.7.5:  lockdep disabled, then crash in skb_queue_tail.
Date: Tue, 29 Jan 2013 22:20:01 -0800
Message-ID: <5108BB91.6070308@candelatech.com>
References: <5108B11F.2080803@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39205 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140Ab3A3GUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 01:20:07 -0500
Received: from [50.54.140.2] (50-54-140-2.evrt.wa.frontiernet.net [50.54.140.2])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r0U6K66W000525
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 22:20:07 -0800
In-Reply-To: <5108B11F.2080803@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2013 09:35 PM, Ben Greear wrote:
> This is from a slightly modified 3.7.5 kernel.
>
> Test case is 2 VAPs, 10 wifi stations, some 'veth' interfaces, etc.  This
> appeared to happen during configuration of the interfaces, right after
> system boot.
>
> It seems impossible that the skb is null, but maybe it's some general
> corrupted memory bug or something...gah!

This was probably caused by the bug already fixed by the commit below.
Seems this just hasn't quite made it to the -stable release yet....


commit 1adb2e2b5f85023d17eb4f95386a57029df27c88
Author: Felix Fietkau <nbd@openwrt.org>
Date:   Wed Jan 9 16:16:53 2013 +0100

     ath9k: fix double-free bug on beacon generate failure

     When the next beacon is sent, the ath_buf from the previous run is reused.
     If getting a new beacon from mac80211 fails, bf->bf_mpdu is not reset, yet
     the skb is freed, leading to a double-free on the next beacon tx attempt,
     resulting in a system crash.

     Cc: stable@vger.kernel.org
     Signed-off-by: Felix Fietkau <nbd@openwrt.org>
     Signed-off-by: John W. Linville <linville@tuxdriver.com>

I've added this patch and will continue to test...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
