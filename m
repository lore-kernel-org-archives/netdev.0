From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Modifying the exponential backoff on new connection SYN packets
Date: Tue, 09 Apr 2013 09:03:38 -0700
Message-ID: <1365523418.3887.149.camel@edumazet-glaptop>
References: <5163DA09.5070202@wildgooses.com>
	  <1365515283.3887.124.camel@edumazet-glaptop>
	 <1365520328.3887.141.camel@edumazet-glaptop>
	 <51643935.6070201@wildgooses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Ed W <lists@wildgooses.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:40025 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936287Ab3DIQDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 12:03:42 -0400
Received: by mail-pd0-f181.google.com with SMTP id y10so3820691pdj.40
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 09:03:41 -0700 (PDT)
In-Reply-To: <51643935.6070201@wildgooses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-09 at 16:52 +0100, Ed W wrote:
> On 09/04/2013 16:12, Eric Dumazet wrote:
> > On Tue, 2013-04-09 at 06:48 -0700, Eric Dumazet wrote:
> >
> >> You'll have to change inet_csk_reqsk_queue_prune() in
> >> net/ipv4/inet_connection_sock.c
> >>
> >> timeo = min(timeout << req->num_timeout, max_rto);
> >> req->expires = now + timeo;
> >>
> >> Good luck !
> > Oh well, this code is for SYNACK retransmits...
> >
> > For other retransmits, you'll have to take a look in
> > net/ipv4/tcp_timer.c, around lines 475
> >
> > icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
> >
> >
> 
> Hmm, I don't necessarily want to change the normal data timeouts, just 
> the initial SYN timeouts. How might I make detect that I'm in SYN state 
> and cap the timer appropriately? Apologies for beginner questions...

You'll have to add a test on :

if (sk->sk_state == TCP_SYN_SENT)

should be pretty easy.
