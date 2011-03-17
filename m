From: David Miller <davem@davemloft.net>
Subject: Re: build breakage due to br_multicast.c referencing
 ipv6_dev_get_saddr()
Date: Thu, 17 Mar 2011 06:00:33 -0700 (PDT)
Message-ID: <20110317.060033.193708621.davem@davemloft.net>
References: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
	<20110316082441.45db3018@nehalam>
	<4D81CDF6020000780003700B@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linus.luessing@web.de
To: JBeulich@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52926
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754057Ab1CQM74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 08:59:56 -0400
In-Reply-To: <4D81CDF6020000780003700B@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@novell.com>
Date: Thu, 17 Mar 2011 08:01:42 +0000

>>>> On 16.03.11 at 16:24, Stephen Hemminger <shemminger@linux-foundation.org>
> wrote:
>> On Wed, 16 Mar 2011 12:34:19 +0000
>> "Jan Beulich" <JBeulich@novell.com> wrote:
>> 
>>> With BRIDGE=y and IPV6=m commit
>>> fe29ec41aaa51902aebd63658dfb04fe6fea8be5 ("bridge: Use IPv6
>>> link-local address for multicast listener queries") causes the build to
>>> break.
>> 
>> Rather than continue with the config games, lets just make the necessary
>> ipv6 pieces accessible.
> 
> The below (however ugly it may look) seems to do the trick for me,
> for this particular symbol. Possibly other symbols need doing the
> same (didn't check which ones e.g. infiniband depends on), so
> some sort of abstraction might be desirable to make the whole
> thing look less ugly.

Sorry, we won't be doing things this way.  We created the disable
option exactly to handle this cleanly, and that is the way you
should take care of the situation you're in where you want to built
ipv6 modular yet have it disabled.
