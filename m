From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 22:33:18 +0200
Message-ID: <4884F28E.6040903@trash.net>
References: <4883E465.4050405@trash.net> <Xine.LNX.4.64.0807212143540.17349@us.intercode.com.au> <48847BA5.2020600@trash.net> <20080721.102852.124418551.davem@davemloft.net> <alpine.LFD.1.10.0807211037200.31863@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080300090301050900050208"
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47201 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbYGUUdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:33:24 -0400
In-Reply-To: <alpine.LFD.1.10.0807211037200.31863@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080300090301050900050208
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Linus Torvalds wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Mon, 21 Jul 2008 14:05:57 +0200
>>
>>> The idea was that NETFILTER_ADVANCED=n enables everything needed
>>> by mainstream distributions and hides the rest. We can certainly
>>> change the default for this option, but that makes NETFILTER_ADVANCED
>>> pretty much useless.
>> A new feature cannot possibly be used by existing distributions.  I
>> think that's the main gripe.
 >
> 
> Well, if the feature really is going to be something that a _normal_ 
> netfilter config needs, then it should indeed be turned on.

As I said, I don't know whether its needed, but judging by James'
response, its going to be needed for a regular FC installation.

Its not needed today of course, so the attached patch changes it
to depend on NETFILTER_ADVANCED and removes the default.

> However, nothing in the docs imply that at all. Can you explain? Why 
> should IP_NF_SECURITY be on, and why should a default netfilter table 
> enable it? And if it should, WHY THE HELL IS IT DOCUMENTED THAT YOU SHOULD 
> SAY 'N'?

I think I'll just change all the help texts for options having
different defaults with NETFILTER_ADVANCED=n to say "If unsure,
choose the default" to remove the contradictions we'd otherwise
always have.


--------------080300090301050900050208
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

netfilter: make security table depend on NETFILTER_ADVANCED

Signed-off-by: Patrick McHardy <kaber@trash.net>
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index f23e60c..90eb7cb 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -369,7 +369,7 @@ config IP_NF_SECURITY
 	tristate "Security table"
 	depends on IP_NF_IPTABLES
 	depends on SECURITY
-	default m if NETFILTER_ADVANCED=n
+	depends on NETFILTER_ADVANCED
 	help
 	  This option adds a `security' table to iptables, for use
 	  with Mandatory Access Control (MAC) policy.
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 689dec8..0cfcce7 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -213,7 +213,7 @@ config IP6_NF_SECURITY
        tristate "Security table"
        depends on IP6_NF_IPTABLES
        depends on SECURITY
-       default m if NETFILTER_ADVANCED=n
+       depends on NETFILTER_ADVANCED
        help
          This option adds a `security' table to iptables, for use
          with Mandatory Access Control (MAC) policy.

--------------080300090301050900050208--
