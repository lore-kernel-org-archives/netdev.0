From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Questions about IPsec and Netfilter
Date: Thu, 10 May 2007 11:43:26 -0400
Message-ID: <20070510154326.GB8754@csclub.uwaterloo.ca>
References: <Pine.LNX.4.44L0.0705101019350.2600-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Networking development <netdev@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:51353 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754689AbXEJPn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 11:43:27 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.0705101019350.2600-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 10:36:14AM -0400, Alan Stern wrote:
> I've got a few questions about the relationship between the IPsec 
> implementation and Netfilter.
> 
> Q1: At what points during packet processing do the IPsec transformations 
> occur?  In particular, which netfilter hooks do they come before and 
> after?  And likewise, which routing operations do they come before and 
> after?

Are you using netkey or klips?

> Q2: When a packet using IPsec tunnel mode is encapsulated or 
> de-encapsulated, does the newly-formed packet return to some earlier point 
> in the stack for further netfilter processing or routing?  What about 
> transport mode?

As far as I can tell the encrypted packet goes in the INPUT chain, then
is decrypted and goes back in either INPUT or FORWARD depending on the
unencrypted source/destination.  Well for netkey anyhow.  klips goes in
the INPUT chain and then is decrypted and then comes in the ipsecX
interface either on INPUT or FORWARD chains.

> Q3: How can iptables rules determine whether they are dealing with a 
> packet which has been de-encapsulated from (or encapsulated within) an 
> IPsec wrapper?

If using netkey, and 2.6.16 or newer, then the policy tag will be ipsec
if it was decrypted from an ipsec tunnel.  I recently had to upgrade to
shorewall 3.x to deal with that when I wnet to using netkey and 2.6.18
kernel together.  With klips the packets from an ipsec tunnel arive on
the ipsecX interface after being decrypted so you can recognize them
that way.

> Q4: Is it true that NAT-Traversal isn't implemented for transport mode?

No idea.

> In RFC 2401 (Security Architecture for the Internet Protocol), section 5
> includes this text:
> 
>    As mentioned in Section 4.4.1 "The Security Policy Database (SPD)",
>    the SPD must be consulted during the processing of all traffic
>    (INBOUND and OUTBOUND), including non-IPsec traffic.  If no policy is
>    found in the SPD that matches the packet (for either inbound or
>    outbound traffic), the packet MUST be discarded.
> 
> But on Linux systems, by default the SPD is normally empty (as shown by
> "setkey -DP") and all packets are allowed to pass unhindered.
> 
> Q5: Isn't this a violation of the RFC?  Or is there some implicit policy 
> entry which accepts all packets without applying any security association?
> 
> Thanks for any answers.  I may think up more questions later...

--
Len Sorensen
