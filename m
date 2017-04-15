From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: TPACKET_V3 timeout bug?
Date: Sat, 15 Apr 2017 18:45:36 -0400
Message-ID: <20170415224530.GA21010@oracle.com>
References: <20170415194042.GA5936@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34538 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754649AbdDOWpw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 18:45:52 -0400
Content-Disposition: inline
In-Reply-To: <20170415194042.GA5936@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (04/15/17 21:40), Andrew Lunn wrote:
> 
> In my case, lan3 is up and idle, there are no packets flying around to
> be captured. So i would expect pcap_next_ex() to exit once a second,
> with a return value of 0. But it is not, it blocks and stays blocked.
   :
> Looking at the libpcap source, the 1000ms timeout is being used as
> part of the setsockopt(3, SOL_PACKET, PACKET_RX_RING, 0xbe9445c0, 28)
> call, req.tp_retire_blk_tov is set to the timeoutval.

right, aiui, the retire_blk_tov will only kick in if we have at
least one frame in a block, but the block is not filled up yet,
before the req.tp_retire_blk_tov (1s in your case) expires.

If there are 0 frames pending, we should not be waking up the app,
so everything seems to be behaving as it should?

--Sowmini
