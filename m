From: Jesper Juhl <jj@chaosbits.net>
Subject: Dead code in Starfire driver (set_vlan_mode())
Date: Thu, 28 Jul 2011 22:35:40 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1107282229460.20477@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ion Badulescu <ionut@badula.org>, becker@scyld.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:13707 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755690Ab1G1Ufl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 16:35:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In drivers/net/starfire.c::set_vlan_mode() there is this code:

...
	if (vlan_count == 32) {
		ret |= PerfectFilterVlan;
		while (vlan_count < 32) {
...

We've just tested 'vlan_count' as being equal to '32', so it's a bit silly 
to follow that up with a loop that's conditioned on the variable being 
less than that - it will never execute.

Now I don't know this code at all, so I have no idea what the proper fix 
is (just remove the loop? change the loop condition? something else?), but 
I do know that the current code makes little sense ;-)

Just for your information.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

