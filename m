From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] packet: call fanout_release, while UNREGISTERING a
 netdev
Date: Thu, 02 Feb 2017 09:12:24 -0800
Message-ID: <1486055544.13103.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1475676774-18726-1-git-send-email-anoob.soman@citrix.com>
         <20161006.205052.1380596858044266995.davem@davemloft.net>
         <1485797189.6360.98.camel@edumazet-glaptop3.roam.corp.google.com>
         <10e9ac4b-585e-2878-0141-f00020a027f0@citrix.com>
         <1485805493.6360.113.camel@edumazet-glaptop3.roam.corp.google.com>
         <d2b23842-f6db-c2c9-d22c-d7e0945abc15@citrix.com>
         <1485885650.6360.122.camel@edumazet-glaptop3.roam.corp.google.com>
         <61fb944f-776c-00ff-dd05-d33e263f205a@citrix.com>
         <60cc2983-9985-055a-39cd-e9dbec4f7a57@citrix.com>
         <1486050822.13103.44.camel@edumazet-glaptop3.roam.corp.google.com>
         <36ea65c1-f8d4-9732-44b0-628294e2357c@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Anoob Soman <anoob.soman@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35633 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751465AbdBBRM0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 12:12:26 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so1881993pfa.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 09:12:26 -0800 (PST)
In-Reply-To: <36ea65c1-f8d4-9732-44b0-628294e2357c@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-02 at 16:44 +0000, Anoob Soman wrote:
> On 02/02/17 15:53, Eric Dumazet wrote:
> > On Thu, 2017-02-02 at 14:42 +0000, Anoob Soman wrote:
> >
> >> I have tested both the approaches and LOCKDEP doesn't seem to catch any
> >> problem with the test I was doing.
> > Yeah, I think I will cleanup this mess, we probably can remove rcu
> > locking in control path, and stick to a single mutex to reduce all this
> > lock complexity.
> >
> > But that will be for net-next, while we need your fix for net tree.
> >
> > Thanks.
> >
> >
> Sorry, I didn't get it. You want me to post a patch for net tree, 
> changing the way we do dev_{add,remove}_pack(fanout_prot_hook) and you 
> will fix up the lock mess in net-next.

Yes. Please send your patch.

In the future (~1 month when net-next is re-open) I will submit a patch
to remove all these complexity out of af_packet.

Once fast path uses RCU, control path does not need to use a galaxy of
spinlocks and mutexes, and rcu.

This is too complex to maintain. A single mutex should be more than
enough.
