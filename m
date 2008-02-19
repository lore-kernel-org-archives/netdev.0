From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Tue, 19 Feb 2008 15:52:43 -0800
Message-ID: <1203465163.13495.102.camel@dell>
References: <47BA0984.2070306@cybernetics.com>
 <1203381120.13495.78.camel@dell>
 <20080218.163554.74130592.davem@davemloft.net>
 <1203383046.13495.87.camel@dell> <47BB00EC.3010607@cybernetics.com>
 <1203448265.13495.95.camel@dell> <47BB54C2.6090501@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev <netdev@vger.kernel.org>, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: "Tony Battersby" <tonyb@cybernetics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4104 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751703AbYBSXuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 18:50:16 -0500
In-Reply-To: <47BB54C2.6090501@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-02-19 at 17:14 -0500, Tony Battersby wrote:

> 
> Update: when I revert Herbert's patch in addition to applying your
> patch, the iSCSI performance goes back up to 115 MB/s again in both
> directions.  So it looks like turning off SG for TX didn't itself cause
> the performance drop, but rather that the performance drop is just
> another manifestation of whatever bug is causing the data corruption.
> 
> I do not regularly use wireshark or look at network packet dumps, so I
> am not really sure what to look for.  Given the above information, do
> you still believe that there is value in examining the packet dump?
> 

Can you confirm whether you're getting TCP checksum errors on the other
side that is receiving packets from the 5701?  You can just check
statistics using netstat -s.  I suspect that after we turn off SG,
checksum is no longer offloaded and we are getting lots of TCP checksum
errors instead that are slowing the performance.

