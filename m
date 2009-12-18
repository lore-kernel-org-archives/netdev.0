From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] iplink: add macvlan options for bridge mode
Date: Fri, 18 Dec 2009 14:45:07 +0100
Message-ID: <200912181445.07756.arnd@arndb.de>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <1258497551-25959-5-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: linux-kernel@vger.kernel.org, Anna Fischer <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:62614 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbZLRNpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 08:45:35 -0500
In-Reply-To: <1258497551-25959-5-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ping!

Stephen, I submitted this twice but never heard back from you.
The changes to macvlan have been merged in 2.6.33-rc1, so it
would be good to have this included as well.

	Arnd

On Tuesday 17 November 2009, Arnd Bergmann wrote:
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

