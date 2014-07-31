From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel(ipv4): fix tunnels with "local any remote
 $remote_ip"
Date: Wed, 30 Jul 2014 17:16:43 -0700 (PDT)
Message-ID: <20140730.171643.580498897333179169.davem@davemloft.net>
References: <20140729030752.d156e9522754e8a6262541ec@qrator.net>
	<CAHA+R7P3gN6Xd==bF9r=396DBi=sTab7tHgZr4agiLxDBdrk+g@mail.gmail.com>
	<20140729214931.9ae11fe3ddfd49ca6f499db6@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org,
	pinkbyte@gentoo.org, edumazet@google.com, therbert@google.com
To: ixaphire@qrator.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbaGaAQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 20:16:47 -0400
In-Reply-To: <20140729214931.9ae11fe3ddfd49ca6f499db6@qrator.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Popov <ixaphire@qrator.net>
Date: Tue, 29 Jul 2014 21:49:31 +0400

> On Mon, 28 Jul 2014 16:39:23 -0700
> Cong Wang <cwang@twopensource.com> wrote:
> 
>> On Mon, Jul 28, 2014 at 4:07 PM, Dmitry Popov <ixaphire@qrator.net> wrote:
>> >         if (dst) {
>> > -               if (dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
>> > +               if (!dst->obsolete || dst->ops->check(dst, cookie)) {
>> > +                       *saddr = idst->saddr;
>> > +               } else {
>> 
>> I am wondering if this always works, that is, if saddr could be still valid
>> as long as dst is valid?
> 
> Right, this is not a very smooth place, but a) it should work with current ipv4
> route implementation (it obsoletes all dst_entries on any route/addr change).
> Yes, we shouldn't rely on implementation, but b) I don't know how (and why) this
> implementation should be changed to break it. I think the assumption that
> dst_entry is obsoleted when saddr is changed is pretty natural.
> Please correct me if I'm wrong.

Indeed, that is the current state of affairs and I can't see how we'd ever
change this in a way that would break this.

So patch applied, thank you.
