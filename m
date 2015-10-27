From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sock: don't enable netstamp for af_unix sockets
Date: Tue, 27 Oct 2015 07:15:09 -0700
Message-ID: <1445955309.7476.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445863897-22646-1-git-send-email-hannes@stressinduktion.org>
	 <20151026131928.GA1820@netboy>
	 <1445866379.133031.420389177.3AE9E175@webmail.messagingengine.com>
	 <20151027101157.GA1850@netboy>
	 <1445944161.1336457.421364569.5449BCCB@webmail.messagingengine.com>
	 <1445944516.1337466.421368457.2463FECE@webmail.messagingengine.com>
	 <1445951975.7476.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1445953468.1370159.421485969.5DA0A8B3@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33678 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219AbbJ0OPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 10:15:12 -0400
Received: by pabla5 with SMTP id la5so31016341pab.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 07:15:12 -0700 (PDT)
In-Reply-To: <1445953468.1370159.421485969.5DA0A8B3@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-27 at 14:44 +0100, Hannes Frederic Sowa wrote:
> 
> On Tue, Oct 27, 2015, at 14:19, Eric Dumazet wrote:
> > On Tue, 2015-10-27 at 12:15 +0100, Hannes Frederic Sowa wrote:
> > 
> > > Also counter question: why is the netstamp code protected by a
> > > static_key otherwise if not for trying to suppress the code path as
> > > often as possible if not used? ;)
> > 
> > Any idea of why timestamping is asked on AF_UNIX in the first place ?
> 
> I guess syslog code want's to have more accurate timetstamps on when the
> packet is send.
> 
> > For messages sent/received on af_unix sockets, in which place timestamp
> > is taken ?
> 
> in unix_sendmsg on the sending unix socket (we check peer unix socket
> for timestamp flag).
> 
> > Is it at the time skb is cooked and stored in receive queue, or the time
> > it was dequeued ?
> 
> No, at time it is send by sendmsg on the sending socket.
> 
> > In any case, is your patch changing af_unix behavior ? It is not clear
> > from your changelog...
> 
> No, af_unix logic does not pass this logic at all, so we don't need to
> care about netstamp code. netstamp_needed is private to dev.c.

Thanks for clarifying

Acked-by: Eric Dumazet <edumazet@google.com>
