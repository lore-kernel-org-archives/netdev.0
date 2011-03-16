From: Brian Haley <brian.haley@hp.com>
Subject: Re: build breakage due to br_multicast.c referencing	 ipv6_dev_get_saddr()
Date: Wed, 16 Mar 2011 13:34:12 -0400
Message-ID: <4D80F494.6050906@hp.com>
References: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linus.luessing@web.de, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: Jan Beulich <JBeulich@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:43638 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218Ab1CPRer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 13:34:47 -0400
In-Reply-To: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2011 08:34 AM, Jan Beulich wrote:
> With BRIDGE=y and IPV6=m commit
> fe29ec41aaa51902aebd63658dfb04fe6fea8be5 ("bridge: Use IPv6
> link-local address for multicast listener queries") causes the build to
> break.
> 
> Similary, even if both are =m, but ipv6.ko got blacklisted (as is
> happening in various SuSE distros when disabling IPv6), there's
> a runtime problem since bridge.ko then won't load anymore due
> to the missing symbol.

Load the ipv6 module with disable=1, which is why I added it :)

>From Documentation/networking/ipv6.txt:

disable

        Specifies whether to load the IPv6 module, but disable all
        its functionality.  This might be used when another module
        has a dependency on the IPv6 module being loaded, but no
        IPv6 addresses or operations are desired.

        The possible values and their effects are:

        0
                IPv6 is enabled.

                This is the default value.

        1
                IPv6 is disabled.

                No IPv6 addresses will be added to interfaces, and
                it will not be possible to open an IPv6 socket.

                A reboot is required to enable IPv6.

-Brian
