From: Vitaliy Gusev <vgusev@openvz.org>
Subject: Re: [PATCH net-2.6] ip: NULL pointer dereferrence in tcp_v(4|6)_send_ack
Date: Wed, 1 Oct 2008 13:06:15 +0400
Message-ID: <200810011306.15745.vgusev@openvz.org>
References: <200809302013.30051.vgusev@openvz.org> <1222792151-11861-1-git-send-email-den@openvz.org> <20081001.015246.92774687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, xemul@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:14967 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753607AbYJAI6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 04:58:34 -0400
In-Reply-To: <20081001.015246.92774687.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 October 2008 12:52:46 David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Tue, 30 Sep 2008 20:29:11 +0400
> 
> > The following actions are possible:
> > tcp_v4_rcv
> >   skb->dev = NULL;
> >   tcp_v4_do_rcv
> >     tcp_v4_hnd_req
> >       tcp_check_req
> >         req->rsk_ops->send_ack == tcp_v4_send_ack
> > 
> > So, skb->dev can be NULL in tcp_v4_send_ack. We must obtain namespace
> > from dst entry. IPv6 codepath is similar.
> > 
> > Thanks to Vitaliy Gusev <vgusev@openvz.org> for initial oops decoding.
> > 
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> Vitaliy sent the same patch first, so I applied his copy :-)

Den's patch is not the same. My patch didn't fix IPv6 code.

> 
> Thanks everyone.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 



-- 
Thank,
Vitaliy Gusev
