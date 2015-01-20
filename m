From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/2] vxlan: Eliminate dependency on UDP socket
 in transmit path
Date: Tue, 20 Jan 2015 18:13:35 +0000
Message-ID: <20150120181335.GL20315@casper.infradead.org>
References: <1421518700-22460-1-git-send-email-therbert@google.com>
 <1421518700-22460-3-git-send-email-therbert@google.com>
 <20150119085938.GG20315@casper.infradead.org>
 <CA+mtBx-QVcK2yP7hwr01X-KaXedzrgMGrHH503-i5y54BPnNPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33077 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbbATSNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 13:13:36 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx-QVcK2yP7hwr01X-KaXedzrgMGrHH503-i5y54BPnNPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/15 at 09:29am, Tom Herbert wrote:
> I didn't see any reason to preclude that, if it needs to be symmetric
> in that case it can be forced at the configuration. Being able to
> receive RCO but not have to send it to certain peers is important use
> case. You may want to consider this also for GBP if there are cases
> where we accept GBP from different peers, but only send it to certain
> ones.

I think asymmetric configurations are fine, in particular
receive-only. I was reluctant to the send-only scenario initially
as I would expect a VTEP sending RCO frames on UDP dport 8472 to
also always be able to accept RCO frames on that port. I can't
come up with any specific cases where this would lead to problems
though so I have no objections.

As for GBP, as processing of the policy group requires additional
iptables or OVS rules anyway, such behaviour would be implemented
in those rules by either ignoring the mark or dropping such frames.
