From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to
	use rtnl_notify()
Date: Wed, 16 Aug 2006 08:04:24 -0400
Message-ID: <1155729864.5122.95.camel@jzny2>
References: <20060815122300.GV14627@postel.suug.ch>
	 <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
	 <20060816105856.GW14627@postel.suug.ch>
	 <20060816111240.GA28846@gondor.apana.org.au>
	 <20060816113950.GA29003@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, hasso@estpak.ee, kuznet@ms2.inr.ac.ru,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:19078 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751122AbWHPMEh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 08:04:37 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GDK8V-0001Ve-8s
	for netdev@vger.kernel.org; Wed, 16 Aug 2006 08:04:39 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060816113950.GA29003@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-16-08 at 21:39 +1000, Herbert Xu wrote:

> So let's step back a bit and think about where does this pid really
> come from.  The field in question is nlmsg_pid.  Its primary purpose
> is to identify unicast transactions along with the field nlmsg_seq.
> It was not designed to identify the origin of a broadcast kernel
> notification to a third party.

There are quiet a few things that netlink design intent was not
intending to solve that became needed over time. This being one IMHO.
Design intent and eventual (sometimes creative) use occasionally create
an impedance ;-> Evolution is the only description i can think of.

> For this purpose, the value of nlmsg_pid is set to the address of
> the destination socket for a particular unicast message (also known
> as the pid).

Since we are talking history:
The idea of it being a destination socket _was not_ design intent. It
was evolution. I recall James Morris actually to be the first person
whining about this ambiguity when coding up nfqueue. I cant remember who
fixed it (I am inclined to think it was you;->)
 
> That pid in turn has only a vague connection with the process ID
> of the process owning the socket.  For practical purposes, we
> should not treat it as a process ID it can easily be claimed by
> another process (think socket + bind + fork).

If you want to be complete the kernel should "fix" the pid in
netlink::sendmsg().

> For a broadcast notification, the nlmsg_pid field is meaningless
> because the nlmsg_seq field is also meaningless.  

nlmsg_seq is meaningless; "seq" is again a bad noun. It should be
"cookie".

> I'm not denying
> that it wouldn't be useful to have the originator's socket address
> in there.  What I'm saying is that it's the wrong place to put
> that information.
>
> In any case, putting current->pid in this field is definitely
> a bad idea because it only encourages people to confuse the
> netlink pid with the process ID which can lead to security
> problems later on.

current->pid i think is coming out to be a bad idea. Thomas' patches
revert it out. Again this has everything to do with the original idea
what maps to pid now changing to socketid.

What do you think of the idea of infact rewriting the pid to be that of
the socket id?

cheers,
jamal

