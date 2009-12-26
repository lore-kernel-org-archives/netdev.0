From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH, resend] iproute2/iplink: add macvlan options for bridge
 mode
Date: Sat, 26 Dec 2009 11:24:11 -0800
Message-ID: <20091226112411.0ab90bd4@nehalam>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de>
	<200911271157.25748.linux-kernel-owner@vger.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58719 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbZLZTY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Dec 2009 14:24:28 -0500
In-Reply-To: <200911271157.25748.linux-kernel-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Nov 2009 10:57:25 +0000
Arnd Bergmann <arnd@arndb.de> wrote:

> Macvlan can now optionally support forwarding between its
> ports, if they are in "bridge" mode. This adds support
> for this option to "ip link add", "ip link set" and "ip
> -d link show".
> 
> The default mode in the kernel is now "vepa" mode, meaning
> "virtual ethernet port aggregator". This mode is used
> together with the "hairpin" mode of an ethernet bridge
> that the parent of the macvlan device is connected to.
> All frames still get sent out to the external interface,
> but the adjacent bridge is able to send them back on
> the same wire in hairpin mode, so the macvlan ports
> are able to see each other, which the bridge can be
> configured to monitor and control traffic between
> all macvlan instances. Multicast traffic coming in
> from the external interface is checked for the source
> MAC address and only delivered to ports that have not
> yet seen it.
> 
> In bridge mode, macvlan will send all multicast traffic
> to other interfaces that are also in bridge mode but
> not to those in vepa mode, which get them on the way
> back from the hairpin.
> 
> The third supported mode is "private", which prevents
> communication between macvlans even if the adjacent
> bridge is in hairpin mode. This behavior is closer to
> the original implementation of macvlan but stricly
> maintains isolation.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Okay, applied for next version

-- 
