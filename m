From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [PATCH] Fixed TPACKET V3 to signal poll when block is closed rather than every packet
Date: Sun, 1 Feb 2015 18:11:00 -0800
Message-ID: <176300FC-C2D7-40D3-8286-7248FC48B9F7@alum.mit.edu>
References: <1418960965-29522-1-git-send-email-dan@dcollins.co.nz> <20141222.154144.2133538994062884017.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: dan@dcollins.co.nz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d.mail.sonic.net ([64.142.111.50]:43007 "EHLO d.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277AbbBBCVs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2015 21:21:48 -0500
In-Reply-To: <20141222.154144.2133538994062884017.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 22, 2014, at 12:41 PM, David Miller <davem@davemloft.net> wrote:

> From: Dan Collins <dan@dcollins.co.nz>
> Date: Fri, 19 Dec 2014 16:49:25 +1300
> 
>> Make TPACKET_V3 signal poll when block is closed rather than for every
>> packet. Side effect is that poll will be signaled when block retire
>> timer expires which didn't previously happen. Issue was visible when
>> sending packets at a very low frequency such that all blocks are retired
>> before packets are received by TPACKET_V3. This caused avoidable packet
>> loss. The fix ensures that the signal is sent when blocks are closed
>> which covers the normal path where the block is filled as well as the
>> path where the timer expires. The case where a block is filled without
>> moving to the next block (ie. all blocks are full) will still cause poll
>> to be signaled.
>> 
>> Signed-off-by: Dan Collins <dan@dcollins.co.nz>
> 
> Applied, thanks.

Should this be applied to any of the stable kernel branches?  The old behavior is the source of some libpcap/tcpdump/etc. complaints; see, for example, the thread that included

	http://marc.info/?l=linux-netdev&m=140713966510035&w=2
