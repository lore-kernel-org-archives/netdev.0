From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Wed, 28 Oct 2009 22:23:37 +0100
Message-ID: <20091028212337.GA3218@ami.dom.local>
References: <4ACD9255.4020008@gmail.com>
 <20091008090344.GA7409@ff.dom.local>
 <20091008120039.GA8691@ff.dom.local>
 <4AE87EEE.4020703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:56467 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754367AbZJ1VXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 17:23:55 -0400
Received: by bwz27 with SMTP id 27so1525009bwz.21
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2009 14:23:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AE87EEE.4020703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2009 at 06:27:10PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > On Thu, Oct 08, 2009 at 09:03:44AM +0000, Jarek Poplawski wrote:
> > ...
> >> num_tx_queues. But it seems we should rather use more often
> >> real_num_tx_queue in schedulers code like dumps and maybe more
> >> (like e.g. sch_multiq does).
> > 
> > ...i.e. probably everywhere between dev_activate and dev_deactivate
> > all qdisc operations could use real_num_tx_queues (including a test
> > like: netif_is_real_multique), unless I miss something.
> 
> We don't seem to be supporting changing real_num_tx_queues for
> registered devices currently (at least I couldn't find it).
> So I guess it depends on how this would be implemented.
> 
> Simply changing the dev->real_num_tx_queues value while the
> device is down would require qdisc operations to operate on
> all possible queues since the amount of queues in use could
> be changed after the qdisc is created/configured, but before
> the device is set up. This approach has more complications
> like switching between mq and non-mq root qdiscs, taking care
> of non-default root qdisc (cloning them to the new queues), etc.
> 
> A simpler alternative would be to destroy the existing root
> qdisc on any change to real_num_tx_queues and have dev_activate()
> set it up from scratch. In this case, we could (as you suggested)
> use real_num_tx_queues, which should fix the problem Eric reported.

Actually, I changed my mind after Eric's and especially David's
explanations. Probably there will be needed some changes in handling
the real_num_tx_queues, but there is no reason to misuse them for
masking a totally useless num_tx_queues value, like in this case. So,
IMHO, its mainly about the driver(s) (and maybe a bit of API change)
here.

Jarek P.
