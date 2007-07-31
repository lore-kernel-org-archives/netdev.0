From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH] [NET]: fix multicast list when cloning sockets
Date: Tue, 31 Jul 2007 00:00:41 -0300
Message-ID: <39e6f6c70707302000l52926c9ar927fd550467ce3e3@mail.gmail.com>
References: <20070730160448.GA4002@redhat.com>
	 <20070730.190144.26963470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: fleitner@redhat.com, dlstevens@us.ibm.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:59916 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764383AbXGaDAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 23:00:42 -0400
Received: by ug-out-1314.google.com with SMTP id j3so36388ugf
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 20:00:41 -0700 (PDT)
In-Reply-To: <20070730.190144.26963470.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/30/07, David Miller <davem@davemloft.net> wrote:
> From: Flavio Leitner <fleitner@redhat.com>
> Date: Mon, 30 Jul 2007 13:04:48 -0300
>
> >
> > The sock_copy() function uses memcpy() to clone the socket
> > including the struct ip_mc_socklist *mc_list pointer.
> >
> > The ip_mc_drop_socket() function is called when socket is closed
> > to free these objects leaving the other sockets cloned from the
> > same master socket with invalid pointers.
> >
> > This patch sets mc_list of cloned socket to NULL.
> >
> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
>
> Allowing non-datagram sockets to end up with a non-NULL inet->mc_list
> in the first place is a bug.
>
> Multicast subscriptions cannot even be used with TCP and DCCP, which
> are the only two users of these connection oriented socket functions.
>
> The first thing that TCP and DCCP do, in fact, for input packet
> processing is drop the packet if it is not unicast.
>
> Therefore the fix really is for the inet layer to reject multicast
> subscription requests on sockets for which that absolutely does not
> make sense.  There is no reason these functions in
> inet_connection_sock.c should need to be mindful of multicast
> state. :-)

Well, we can add a BUG_ON there then 8)

Flavio, take a look at  do_ip_setsockopt in net/ipv4/ip_sockglue.c, in
the IP_{ADD,DROP}_MEMBERSHIP labels.

Don't forget IPV6 (net/ipv6/ipv6_sockglue.c)

- Arnaldo
