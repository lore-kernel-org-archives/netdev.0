From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Sat, 17 Apr 2010 16:27:25 +0200
Message-ID: <1271514445.16881.4746.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi> <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <z2q65634d661004170143nb35ec784mbedd003565410cfb@mail.gmail.com>
	 <1271496229.16881.4602.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Changli Gao <xiaosuo@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert@herjulf.net, andi@firstfloor.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:37838 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab0DQO1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 10:27:45 -0400
Received: by bwz25 with SMTP id 25so4033536bwz.28
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 07:27:43 -0700 (PDT)
In-Reply-To: <1271496229.16881.4602.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 17 avril 2010 =C3=A0 11:23 +0200, Eric Dumazet a =C3=A9crit :
> Le samedi 17 avril 2010 =C3=A0 01:43 -0700, Tom Herbert a =C3=A9crit =
:
> > > So the cost of queing the packet into our own queue (netif_receiv=
e_skb
> > > -> enqueue_to_backlog) is about 0.74 us  (74 ms / 100000)
> > >
> > > I personally think we should process packet instead of queeing it=
, but
> > > Tom disagree with me.
> > >
> > You could do that, but then the packet processing becomes HOL block=
ing
> > on all the packets that are being sent to other queues for
> > processing-- remember the IPIs is only sent at the end of the NAPI.
> > So unless the upper stack processing is <0.74us in your case, I thi=
nk
> > processing packets directly on the local queue would improve best c=
ase
> > latency, but would increase average latency and even more likely wo=
rse
> > case latency on loads with multiple flows.


Tom, I am not sure what you describe is even respected for NAPI devices=
=2E
(I hope you use napi devices in your company ;) )

If we enqueue a skb to backlog, we also link our backlog napi into our
poll_list, if not already there.

So the loop in net_rx_action() will make us handle our backlog napi a
bit after this network device napi (if time limit of 2 jiffies not
elapsed) and *before* sending IPIS to remote cpus anyway.




