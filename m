From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] igmp: make /proc/net/{igmp,mcfilter} per netns
Date: Thu, 11 Sep 2008 12:59:30 -0700
Message-ID: <OF2D3678ED.2D05BEF6-ON882574C1.006BF3E7-882574C1.006DD1A5@us.ibm.com>
References: <48C9522B.8080002@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	containers@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:48518 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbYIKT7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 15:59:42 -0400
In-Reply-To: <48C9522B.8080002@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel,
        Thanks for the detailed response.

        As long as you have distinct link-local addresses for
each advertiser, I don't see any protocol violations here.

        I don't believe it's all that difficult to do-- the main
thing is simply to push container joins down to the physical
device-- basically don't do any IGMP or MLD processing
in the virtual layer and just pass all that to the device. This
is essentially what is done  already to get multiple sockets
with distinct joins and filter sets boiled down to the right set
of listens to satisfy everything requested.
        Because the link-local addresses are distinct in v6,
it'll work for now, but be a little harder to do there than blindly
passing all advertisements to the device. Instead, you'd want
a shim layer at the device to intercept them and translate them
into joins for the physcal device, which would itself generate
the advertisements.
        Either way you'd want to demultiplex inbound to the
right container.
        I'm interested in looking at this, but I don't own my
time. Feel free to contact me when  you get started and I can
at least review, if not contribute on it.

        I suppose I won't lose sleep at night over it, but
it does mean use of multicasting in containers won't scale
very well until it's addressed.

                                        +-DLS

