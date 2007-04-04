From: jamal <hadi@cyberus.ca>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 04 Apr 2007 06:55:14 -0400
Message-ID: <1175684114.4088.12.camel@localhost>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>
	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>
	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>
	 <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>
	 <20070404020622.M69215@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:31403 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992842AbXDDKzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 06:55:19 -0400
Received: by wx-out-0506.google.com with SMTP id h31so173994wxd
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2007 03:55:18 -0700 (PDT)
In-Reply-To: <20070404020622.M69215@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-04-04 at 05:11 +0300, Denys wrote:
> I think this highly useful feature given by jamal, difficult to be avoided 
> from crash, if user not enough experienced in networking(like me). I guess 
> packet can be even not ipv4/ipv6 packet, maybe it can be cloned IPX or ARP, 
> so TTL field cannot be used. I checked maybe sk_buff have some fields, seems 
> also bad luck, if there can be something like "internal" counter for packet, 
> how much times it got redirected, it will help. 

Adding a field in the skb that keeps track of things would work well,
but would be a controvesial thing to do because it actually requires a
vector not just one field. There is a filed called cb[] but it cant be
used in this case because every time we redirect it could be trampled.

> But in my case of VLAN's it 
> is really my own mistake and difficult to avoid it. Only bad thing - machine 
> got completely locked up, and if it is remote system - it will not oops/or 
> reboot even. But i dont have any idea in mind how to avoid this, only than 
> big warning in DOC and internal iproute2 help :-)

Your case is easy to detect in user space because it is within the same
policy.
Would simple detection and rejection in tc/userspace be useful to add?
Note, this doesnt help the general problem though where you have nesting
as described in the document.

cheers,
jamal

