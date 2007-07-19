From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 14:41:31 +0100
Message-ID: <20070719144131.0c230c8f@oldman.hamilton.local>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com>
	<469E9AC8.3090603@trash.net>
	<m3zm1sbjzl.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	andrei radulescu-banu <iubica2@yahoo.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48005 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753778AbXGSNmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 09:42:49 -0400
In-Reply-To: <m3zm1sbjzl.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 15:28:46 +0200
Krzysztof Halasa <khc@pm.waw.pl> wrote:

> Patrick McHardy <kaber@trash.net> writes:
> 
> > Your suggestion of disabling VLAN acceleration in promiscous
> > mode sounds like a reasonable solution until then ..
> 
> From a user perspective:
> 
> I'm not sure promiscous mode is related to the problem.
> Tcpdump without promiscous mode makes perfect sense.
> 
> I don't know very well VLAN code internals, but I think
> the VLAN # is used for looking up the interface, so
> presenting the "original" packet on the trunk device
> would IMHO involve some skb cloning, and perhaps some
> ethtool option could probably control that.
> 
> Not sure about untagged frames vs. tagged frames with
> the default VLAN id - can the hardware at all differentiate
> between them?
> 
> 
> Or, perhaps it should be left (almost) as is - with "software"
> VLANs the traffic always goes through the master interface,
> but with "accelerated" mode it only goes through logical
> interfaces and doesn't show up on master? Probably with
> exception of invalid VLANs, which could be injected back to
> master (because no logical device exists)?


I don't claim to be a VLAN expert but there are really three cases
for handling tagged frames

1) non-accelerated device 
    * all frames show in promiscious mode
    * tag is part of the frame that shows up
       in tcpdump, and then gets stripped by the 8021q module.
2) rx tag stripping device
     * all frames show in promiscious mode
     * tag is in skb but NOT passed to tcpdump
3) rx vlan acceleration
     * only frames that for vlan's that are registered show up
        in promisicous mode
     * tag is in skb but NOT passed to tcpdump

Unfortunately, the tag is lost as part of the VLAN acceleration process
so it is not a simple matter of changing code in AF_PACKET receive
to restore the tag.
