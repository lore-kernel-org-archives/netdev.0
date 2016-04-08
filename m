From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] vxlan: synchronously and race-free destruction
 of vxlan sockets
Date: Sat, 09 Apr 2016 01:55:06 +0200
Message-ID: <1460159706.2880965.573380353.39845928@webmail.messagingengine.com>
References: <1460148901-23740-1-git-send-email-hannes@stressinduktion.org>
 <CAM_iQpUbTz2dRS+ZTZSSL0AvkOb_2_HEfXo+ap9__aQZmajMjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Benc <jbenc@redhat.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:47519 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754211AbcDHXzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 19:55:07 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 8593A213AE
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2016 19:55:06 -0400 (EDT)
In-Reply-To: <CAM_iQpUbTz2dRS+ZTZSSL0AvkOb_2_HEfXo+ap9__aQZmajMjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, Apr 9, 2016, at 01:24, Cong Wang wrote:
> On Fri, Apr 8, 2016 at 1:55 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > Due to the fact that the udp socket is destructed asynchronously in a
> > work queue, we have some nondeterministic behavior during shutdown of
> > vxlan tunnels and creating new ones. Fix this by keeping the destruction
> > process synchronous in regards to the user space process so IFF_UP can
> > be reliably set.
> >
> > udp_tunnel_sock_release destroys vs->sock->sk if reference counter
> > indicates so. We expect to have the same lifetime of vxlan_sock and
> > vxlan_sock->sock->sk even in fast paths with only rcu locks held. So
> > only destruct the whole socket after we can be sure it cannot be found
> > by searching vxlan_net->sock_list.
> >
> 
> I am wondering what is the reason why we used work queue from
> the beginning?

I actually don't know. It was like that from the beginning. I cc'ed
Stephen, maybe he remembers?

Bye,
Hannes
