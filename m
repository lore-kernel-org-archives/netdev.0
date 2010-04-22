From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 22 Apr 2010 09:27:06 +0800
Message-ID: <y2p412e6f7f1004211827x3e456588jb8e7ad780b891417@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271424065.4606.31.camel@bigi> <1271489739.16881.4586.camel@edumazet-laptop>
	<1271525519.3929.3.camel@bigi> <1271583573.16881.4798.camel@edumazet-laptop>
	<1271590476.16881.4925.camel@edumazet-laptop> <1271764941.3735.94.camel@bigi>
	<1271769195.7895.4.camel@edumazet-laptop> <1271853570.4032.21.camel@bigi>
	<1271876480.7895.3106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:59106 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562Ab0DVB12 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 21:27:28 -0400
Received: by iwn8 with SMTP id 8so1478385iwn.16
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 18:27:27 -0700 (PDT)
In-Reply-To: <1271876480.7895.3106.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 3:01 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> Thanks a lot Jamal, this is really useful
>
> Drawback of using a fixed src ip from your generator is that all flow=
s
> share the same struct dst entry on SUT. This might explain some glitc=
hes
> you noticed (ip_route_input + ip_rcv at high level on slave/applicati=
on
> cpus)
> Also note your test is one way. If some data was replied we would see
> much use of the 'flows'
>
> I notice epoll_ctl() used a lot, are you re-arming epoll each time yo=
u
> receive a datagram ?
>
> I see slave/application cpus hit _raw_spin_lock_irqsave() and
> _raw_spin_unlock_irqrestore().
>
> Maybe a ring buffer could help (instead of a double linked queue) for
> backlog, or the double queue trick, if Changli wants to respin his
> patch.
>
>

OK, I'll post a new patch against the current tree, so Jamal can have
a try. I am sorry, but I don't have a suitable computer for benchmark.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
