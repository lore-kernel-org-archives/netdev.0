From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [PATCH NET-NEXT 0/10] hardware time stamping with new fields
	in shinfo
Date: Thu, 12 Feb 2009 16:03:01 +0100
Message-ID: <1234450981.5914.11.camel@ecld0pohly>
References: <1234450670.5914.9.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Stultz <johnstul@us.ibm.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11950 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760490AbZBLPDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 10:03:05 -0500
In-Reply-To: <1234450670.5914.9.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[once more, with signed-off - sorry for the noise]

This revision of the patch series transports hardware time stamps from
the hardware into user space via additional fields in struct
skb_shared_info. It's based on net-next-2.6 as of this morning.

This is the solution that emerged from the discussion of the other
approaches suggested before (reuse tstamp, extend skbuff, optional
structs): it has the advantage of not touching skbuff and also has the
simplest implementation.

The clocksource and timecompare patches have been reviewed by John
Stultz. He doesn't mind merging them via the net subtree.

John Ronciak reviewed the igb driver patches. He suggested to merge the
patches as they; after all, PTPd already works fine. I just tested again
on 32 and 64 bit x86, both with the timestamping example programs as
well as with PTPd. Latest patched PTPd is here:
        http://github.com/pohly/ptpd/tree/master

The open TODOs in the igb driver will be fixed. We think that this will
be easier with the infrastructure and the driver in a regular kernel
tree.

David, I hope you consider the patches acceptable now. If not, then as
before: please let me know what I can do to make them acceptable.


