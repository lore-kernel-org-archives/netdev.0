From: Julian Anastasov <ja@ssi.bg>
Subject: Re: __pskb_pull_tail oops from 2.6.35
Date: Wed, 28 Sep 2011 10:30:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1109281006380.1552@ja.ssi.bg>
References: <20110927200328.GA22678@redhat.com>  <20110927.160804.528213323197711241.davem@davemloft.net>  <20110927201500.GA27713@redhat.com>  <20110927.161848.1967387021236457958.davem@davemloft.net>  <20110927202405.GB27713@redhat.com>
 <1317155839.2472.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-136697441-1317195001=:1552"
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34888 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751785Ab1I1H3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 03:29:21 -0400
In-Reply-To: <1317155839.2472.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-136697441-1317195001=:1552
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Tue, 27 Sep 2011, Eric Dumazet wrote:

> Le mardi 27 septembre 2011 à 16:24 -0400, Dave Jones a écrit :
> > On Tue, Sep 27, 2011 at 04:18:48PM -0400, David Miller wrote:
> >  > From: Dave Jones <davej@redhat.com>
> >  > Date: Tue, 27 Sep 2011 16:15:00 -0400
> >  > 
> >  > > It looks like it died in put_page..
> >  > > 
> >  > > <1>[  262.574991] IP: [<ffffffff810dca57>] put_page+0x10/0x7c
> >  > > 
> >  > > which is only called in one place..
> >  > > 
> >  > > 1267         for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> >  > > 1268                 if (skb_shinfo(skb)->frags[i].size <= eat) {
> >  > > 1269                         put_page(skb_shinfo(skb)->frags[i].page);
> >  > > 1270                         eat -= skb_shinfo(skb)->frags[i].size;
> >  > > 1271                 } else {
> >  > 
> >  > That's a pretty serious corruption, all frag array entries from 0 to
> >  > nr_frags should have valid, non-NULL page pointers.
> >  > 
> >  > Maybe a LRO/GRO bug?  There were a couple of those.
> > 
> > I'll see if I can talk him into trying a self-built kernel, as we're not
> > rebasing f14 at this point in its life-cycle. If it turns out to still affect
> > 3.x, I'll bring it up again.
> > 
> 
> This could be a struct skb_shared_info -> nr_frags corruption
> 
> (Something was overflowing skb head and overflowing very beginning of
> skb_shared_info in rare circumstances)
> 
> We had such bug in the past, I cant remember details right now.

	I remember for similar problem that was fixed
recently (IPVS+nf_reinject), oops is here:

http://marc.info/?l=linux-virtual-server&m=131098073717449&w=2

	Oops points to put_page but not sure for the call trace.
Code auditing pointed out to be a double kfree_skb issue. Still,
it was never confirmed by the original reporter. May be
problem with double kfree_skb is easier to track in all
modules that play with the packet.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-136697441-1317195001=:1552--
