From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [net-next PATCH 1/4] Revert "inet: limit length of fragment
 queue hash table bucket lists"
Date: Fri, 3 May 2013 11:15:07 +0200
Message-ID: <20130503111507.1f5ec1af@redhat.com>
References: <20130424154624.16883.40974.stgit@dragon>
	<20130424154800.16883.4797.stgit@dragon>
	<1366848030.8964.98.camel@edumazet-glaptop>
	<20130502095955.1ea082fb@redhat.com>
	<1367507801.29805.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762733Ab3ECJPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 05:15:16 -0400
In-Reply-To: <1367507801.29805.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 02 May 2013 08:16:41 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2013-05-02 at 09:59 +0200, Jesper Dangaard Brouer wrote:
> > On Wed, 24 Apr 2013 17:00:30 -0700 Eric Dumazet
> > <eric.dumazet@gmail.com> wrote:
> > 
> > > On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> > > > This reverts commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055.
> > > > 
> > > > The problem with commit 5a3da1fe (inet: limit length of fragment
> > > > queue hash table bucket lists) is that, once we hit the hash
> > > > depth limit (of 128), the we *keep* the existing frag queues,
> > > > not allowing new frag queues to be created.  Thus, an attacker
> > > > can effectivly block handling of fragments for 30 sec (as each
> > > > frag queue have a timeout of 30 sec)
> > > > 
> > > 
> > > I do not think its good to revert this patch. It was a step in
> > > right direction.
> > 
> > We need a revert, because we are too close to the merge window, and
> > cannot complete the needed "steps" to make this patch safe, sorry.
> 
[...]
> 
> For people willing to allow more memory to be used, the only way is to
> resize hash table, or using a bigger INETFRAGS_HASHSZ
>
> I do not think there is a hurry, current defrag code is already better
> than what we had years ago.
 
Eric I think we agree that:
 1) we need resizing of hash table based on mem limit
 2) mem limit per netns "blocks" the hash resize patch

Without these two patches/changes, the static 128 depth limit
introduces an undocumented limit on the max mem limit
setting (/proc/sys/net/ipv4/ipfrag_high_thresh).

I think we only disagree on the order of the patches.

But lets keep this, because after we have increased hash
size (INETFRAGS_HASHSZ) to 1024, we have pushed the "undocumented
limit" so-far that is very unlikely to be hit.  We would have to
start >36 netns instances, all being overloaded with small
incomplete fragments at the same time (30 sec time window).

--Jesper
