From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Wed, 01 Apr 2015 17:48:45 -0700
Message-ID: <1427935725.25985.179.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
	 <CAHA+R7NvbJyjjBac=4VneQ_Nuxtb-_HEOJp0dujh5SOXj3NSKQ@mail.gmail.com>
	 <1427934458.25985.177.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1427934951.1893436.248333749.7DEEB94B@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33548 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbbDBAsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 20:48:50 -0400
Received: by pdrw1 with SMTP id w1so63488514pdr.0
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 17:48:49 -0700 (PDT)
In-Reply-To: <1427934951.1893436.248333749.7DEEB94B@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-02 at 02:35 +0200, Hannes Frederic Sowa wrote:
> 
> On Thu, Apr 2, 2015, at 02:27, Eric Dumazet wrote:
> > On Wed, 2015-04-01 at 17:06 -0700, Cong Wang wrote:
> > 
> > > Shouldn't these skb's be orphaned for tunnel cases? Or we still have
> > > to keep skb->sk for other valid use?
> > 
> > skb should not be orphaned, until the very last stage.
> > 
> > Many layers depend on this, really.
> > 
> > Simply ask the question to yourself :
> > 
> > What if I do not associate skb to a socket at first. What possibly
> > breaks ?
> > 
> > orphaning skb just because they traverse a tunnel would be quite
> > horrible.
> 
> Agreed, but we have some bits in the skb->sk pointer left for signaling
> we are only keeping it around for destructor and upper layer
> notifications. Destructors should be the only ones having to deal with
> skb->sk and they can mask the bit. That would touch a lot of NULL
> checks, though.

Have you checked net/sched/sch_fq.c per chance ?

skb->sk is not an opaque value.
