From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 8 Oct 2008 12:41:16 -0700
Message-ID: <OF4E8F44F8.B83D3AFA-ON882574DC.006B0778-882574DC.006C2639@us.ibm.com>
References: <48ED0615.7000007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:44652 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756627AbYJHTl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 15:41:29 -0400
In-Reply-To: <48ED0615.7000007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, I think the reason to send mulitple of them is identical.
If one is dropped due to network load, it won't happen; sending
multiple increases the odds of success.

DAD itself should update caches for neighboring nodes, so I
guess it makes sense that it isn't sending unsolicited NA's, But
that makes me think that the DAD retransmit counter is the one
you want. At least, the part of the DAD retransmit counter that is
for updating other nodes' caches. :-)

For MLD and IGMP, they were explicit SHOULD's-- I need to have
a look at ND RFC's to again to see what it says about it.

I don't think that alone is a reason to block the patch, but I also
don't think that updating neighbor caches with a new MAC address
is a unique requirement of bonding. Moving an address manually
ought to be identical in needs and behavior, as well as very-quick
reboots where the hardware changed. Thus, I don't think the knob
ought to be specific to bonding. I guess that leads to the suggestion
that you re-use the DAD counter for that.

References to MLD now and before are just me looking for an
analog to what ND should be doing. No new knob is definitely
required for them, since they already have this support for
unsolicited reports.

                                                +-DLS


