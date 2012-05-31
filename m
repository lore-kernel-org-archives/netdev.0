From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN
 floods
Date: Thu, 31 May 2012 14:58:20 +0200
Message-ID: <1338469100.2760.1341.camel@edumazet-glaptop>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <4FC3A465.4030203@uclouvain.be> <1338322661.7747.17.camel@localhost>
	 <4FC53353.2050801@uclouvain.be> <1338367497.7747.72.camel@localhost>
	 <4FC5DFF4.1020604@uclouvain.be> <1338417630.7747.156.camel@localhost>
	 <1338468693.7747.162.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Andi Kleen <andi@firstfloor.org>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54023 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932194Ab2EaM61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 08:58:27 -0400
Received: by bkcji2 with SMTP id ji2so801880bkc.19
        for <netdev@vger.kernel.org>; Thu, 31 May 2012 05:58:25 -0700 (PDT)
In-Reply-To: <1338468693.7747.162.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-31 at 14:51 +0200, Jesper Dangaard Brouer wrote:
> On Thu, 2012-05-31 at 00:40 +0200, Jesper Dangaard Brouer wrote:
> > That seems like a very unlikely situation, which we perhaps should
> > neglect as we are under SYN attack.
> >
> > I will test the attack vector, if we instead of dropping the reqsk,
> > fall back into the slow locked path.
> 
> I can provoke this attack vector, and performance is worse, if not
> dropping the reqsk early.
> 
> Generator SYN flood at 750Kpps, sending false retransmits mixture.
> 
> - With early drop: 406 Kpps
> - With return to locked processing: 251 Kpps
> 
> Its still better than the approx 150Kpps, without any patches.
> 

How many different IP addresses are used by your generator ?

Or maybe you disabled IP route cache ?
