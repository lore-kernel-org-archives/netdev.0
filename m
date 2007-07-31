From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: on [ab]use of skb->cb by VLAN code
Date: Mon, 30 Jul 2007 22:02:04 -0400
Message-ID: <1185847324.5162.31.camel@localhost>
References: <1185843556.5162.8.camel@localhost>
	 <20070730.183337.27784025.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, kaber@trash.net, netdev@vger.kernel.org,
	mcarlson@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:63305 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758515AbXGaCCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 22:02:23 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1516613wxd
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 19:02:22 -0700 (PDT)
In-Reply-To: <20070730.183337.27784025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-30-07 at 18:33 -0700, David Miller wrote:

> I understand the concern, but how much qdisc stuff can possibly
> happen between those two ->hard_start_xmit() calls and do we
> want to support that in any way anyways?

>From a quick glance only netem seems to use it in the fast path (in a
legit way)
Theoretically, you could have many generations (i.e parents and
children, grandchildren etc) of netdevices stacked on top of each other
each with qdiscs. In a simple example: dont know how well these days
Vlans->bonding->somehardwarenetdevice works. 
Redirect will could also result in a graph of unrelated netdevices (and
it is fair game to trample on cb anywhere along the path)
I came across the issue because i used cb in batching to store transient
state which is used between qdisc dequeueing and hardware enqueueing
(looked and smelled legit to me).
 
> The only alternative I see is to add more things to struct sk_buff
> and that's usually very unpopular :-)

I know ;-> Thats why i asked the question.

cheers,
jamal

