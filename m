From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/4] Revert "inet: limit length of fragment
 queue hash table bucket lists"
Date: Thu, 02 May 2013 08:16:41 -0700
Message-ID: <1367507801.29805.12.camel@edumazet-glaptop>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154800.16883.4797.stgit@dragon>
	 <1366848030.8964.98.camel@edumazet-glaptop>
	 <20130502095955.1ea082fb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:39729 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932423Ab3EBPQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 11:16:44 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj3so411060pad.29
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 08:16:44 -0700 (PDT)
In-Reply-To: <20130502095955.1ea082fb@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-02 at 09:59 +0200, Jesper Dangaard Brouer wrote:
> On Wed, 24 Apr 2013 17:00:30 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> > > This reverts commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055.
> > > 
> > > The problem with commit 5a3da1fe (inet: limit length of fragment
> > > queue hash table bucket lists) is that, once we hit the hash depth
> > > limit (of 128), the we *keep* the existing frag queues, not
> > > allowing new frag queues to be created.  Thus, an attacker can
> > > effectivly block handling of fragments for 30 sec (as each frag
> > > queue have a timeout of 30 sec)
> > > 
> > 
> > I do not think its good to revert this patch. It was a step in right
> > direction.
> 
> We need a revert, because we are too close to the merge window, and
> cannot complete the needed "steps" to make this patch safe, sorry.

Again, a limit of 128 is totally OK. Its in fact too big.

128 cache misses consume 5 us

Allowing a chain being non limited is a more severe bug.

Reverting will allow an attacker to consume all your cpu cycles.

We changed INETFRAGS_HASHSZ to 1024, so 128*1024 max frags is already a
very big limit.

No matter what we do, we need to limit both :

- Memory consumption
- Cpu consumption

For people willing to allow more memory to be used, the only way is to
resize hash table, or using a bigger INETFRAGS_HASHSZ

I do not think there is a hurry, current defrag code is already better
than what we had years ago.
