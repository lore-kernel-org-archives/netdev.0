From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v2] vxlan: synchronously and race-free
 destruction of vxlan sockets
Date: Fri, 8 Apr 2016 16:24:28 -0700
Message-ID: <CAM_iQpUbTz2dRS+ZTZSSL0AvkOb_2_HEfXo+ap9__aQZmajMjA@mail.gmail.com>
References: <1460148901-23740-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Benc <jbenc@redhat.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:34017 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbcDHXY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 19:24:29 -0400
Received: by mail-yw0-f171.google.com with SMTP id d68so151958341ywe.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 16:24:28 -0700 (PDT)
In-Reply-To: <1460148901-23740-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 8, 2016 at 1:55 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Due to the fact that the udp socket is destructed asynchronously in a
> work queue, we have some nondeterministic behavior during shutdown of
> vxlan tunnels and creating new ones. Fix this by keeping the destruction
> process synchronous in regards to the user space process so IFF_UP can
> be reliably set.
>
> udp_tunnel_sock_release destroys vs->sock->sk if reference counter
> indicates so. We expect to have the same lifetime of vxlan_sock and
> vxlan_sock->sock->sk even in fast paths with only rcu locks held. So
> only destruct the whole socket after we can be sure it cannot be found
> by searching vxlan_net->sock_list.
>

I am wondering what is the reason why we used work queue from
the beginning?
