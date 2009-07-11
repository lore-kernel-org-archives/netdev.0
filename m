From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH] net:  Fix sk reference counting in
	ip_push_pending_frames and ip6_push_pending_frames
Date: Sat, 11 Jul 2009 20:00:53 +0000
Message-ID: <1247342453.7128.8.camel@Maple>
References: <1247334370.7128.6.camel@Maple>  <4A58EA7B.1000604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f193.google.com ([209.85.216.193]:59253 "EHLO
	mail-px0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbZGKUA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 16:00:58 -0400
Received: by pxi31 with SMTP id 31so1149377pxi.33
        for <netdev@vger.kernel.org>; Sat, 11 Jul 2009 13:00:57 -0700 (PDT)
In-Reply-To: <4A58EA7B.1000604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-07-11 at 21:39 +0200, Eric Dumazet wrote:
> John Dykstra a =C3=A9crit :
> > Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80 "net: No more
> expensive
> > sock_hold()/sock_put() on each tx" used sk_wmem_alloc rather than
> the struct sock reference
> > count to track in-flight transmit-path packets.  However, it missed
> the __sock_put() calls
> > in ip_push_pending_frames() and ip6_push_pending_frames().  This
> results in too-small
> > reference counts when UDP or RAW sockets are used to send more than
> one MTU of data.  This=20
> > in turn could lead to struct sock being freed and reused while it i=
s
> still part of an
> > active socket.
> >=20
> > A wide variety of socket symptoms may be fixed by this patch.  It
> also fixes one cause=20
> > of WARN_ON's in sk_del_node_init() and sk_nulls_del_node_init_rcu()=
=2E
> >=20
> > Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
>=20
> Nice, but are you aware same patch was already posted, and is waiting
> for David
> approval ?
>=20
> http://patchwork.ozlabs.org/patch/29618/

<sigh>  No, I wasn't.  It took me a while to track down where the
reference counts were going wrong, and during that time I wasn't
tracking netdev traffic.

At least it's fixed.

  --  John

