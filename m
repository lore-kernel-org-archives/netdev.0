From: Octavian Purdila <octavian.purdila@intel.com>
Subject: Re: [RFC] tcp: add support for scheduling TCP options on TCP sockets
Date: Wed, 7 May 2014 21:15:54 +0300
Message-ID: <CAE1zotLxNPSpksBbKu6Z1MrcgdnFGxK8E-6c+fT6csEcQmFOsw@mail.gmail.com>
References: <1399399524-28550-1-git-send-email-octavian.purdila@intel.com>
	<20140507.013820.1357850416047414291.davem@davemloft.net>
	<bc98535539ef4d2c9cb6f53f85068b65@UCL-MBX03.OASIS.UCLOUVAIN.BE>
	<20140507134620.GF4686@cpaasch-mac>
	<906b020ccf1b4e1b98ac414147259a65@UCL-MBX03.OASIS.UCLOUVAIN.BE>
	<20140507141108.GG4686@cpaasch-mac>
	<CAE1zot+L0WVdxSRX7gUSU7V52X0qdk2mTrsXaCAbGmPRu6=Yog@mail.gmail.com>
	<1399476728.15399.146.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33403 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaEGSP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 14:15:56 -0400
Received: by mail-wi0-f181.google.com with SMTP id n15so1824334wiw.14
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 11:15:54 -0700 (PDT)
In-Reply-To: <1399476728.15399.146.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2014 at 6:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-05-07 at 18:17 +0300, Octavian Purdila wrote:
>
>>
>> That would require adding a new field to sk_buff to keep track of how
>> much we need to copy in pskb_copy. Fortunately it seems it has some
>> holes we could use.
>>
>> David, does that seem reasonable?
>
> MPTCP and/or Minion could be implemented in user land, with a generic
> infrastructure in the kernel to directly pass raw packets once demux
> has been done by the kernel.
>

Implementing MPTCP in userspace makes a lot of sense to me as you can
naturally consider MPTCP as a layer on top of TCP. Passing raw packets
is one option, another one is creating the infrastructure to
send/receive TCP options with standard TCP sockets APIs like sendmsg
or recvmsg.

The first option is more flexible, but on the other hand (at least for
MPTCP), it means that userspace must duplicate the "basic" TCP
functionality. The second option allows one to reuse the TCP stack in
kernel while adding new functionality on top of that.

> Large CDN cant always assume multi paths to hit a particular destination
> can all originate from a single host in the datacenter.
>
> MPTCP has this hard assumption from day one.
>
> Our team try to focus on making TCP better, we believe all these
> experimental features do not belong to the kernel yet.

I hear you, the TCP stack is already very complex. That is why I am
looking at ways to manage the increased complexity that MPTCP brings
by using a layered approach.
