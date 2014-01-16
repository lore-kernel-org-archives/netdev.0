From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V2 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag to IPV6_FL_A_GET
Date: Thu, 16 Jan 2014 14:07:53 +0100
Message-ID: <20140116130753.GE7436@order.stressinduktion.org>
References: <1389785403-6401-1-git-send-email-florent.fourcot@enst-bretagne.fr> <20140115224726.GH19945@order.stressinduktion.org> <20140116123515.GD7436@order.stressinduktion.org> <52D7D45E.6000908@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42441 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbaAPNHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 08:07:54 -0500
Content-Disposition: inline
In-Reply-To: <52D7D45E.6000908@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 01:45:18PM +0100, Florent Fourcot wrote:
> 
> >> Was there a specific reason you did not use np->flow_label here and just
> >> mirroring the flowlabel from the first packet of the connection for the
> >> whole connection?
> >>
> >> I don't know if it makes a difference, but maybe it was done on purpose?
> > 
> > I thought about it and am actually in favor of reusing the flowid from the syn
> > packet so userspace does report correct outgoing flowlabel even in case of
> > strange tcp peer changing it mid-stream.
> > 
> 
> Actually, the idea was that the remote could changed the flow label
> during the lifetime of a connection.
> I do not have a strong opinion on that, but in a "reflect" mode, I
> except that the last received value will be in used.

Would it make sense to sync the flowlabel if it changes with the socket, so
user space can query the label really used? Otherwise I wouldn't even report
it.

> Second, in case of SYN cookie, is the SYN flow label stored somewhere?

Should then be synced as soon as the cookie is validated. You can test it by
setting tcp_syncookies to 2. It uses syncookies unconditionally then.

Greetings,

  Hannes
