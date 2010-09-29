From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6] ip_gre: lockless xmit
Date: Wed, 29 Sep 2010 12:24:28 -0700
Message-ID: <AANLkTin1wAJ9kTJeVbFAzu0D3cJFP1J8V1aiHhXGvaaT@mail.gmail.com>
References: <1285664747.2607.48.camel@edumazet-laptop>
	<AANLkTinCz_0jHsMYW9_Wko78i9U20qefFbTYCQQQ-pz5@mail.gmail.com>
	<1285785794.2813.292.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:62920 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754912Ab0I2TYg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 15:24:36 -0400
Received: by iwn5 with SMTP id 5so1386824iwn.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 12:24:35 -0700 (PDT)
In-Reply-To: <1285785794.2813.292.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 29, 2010 at 11:43 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mercredi 29 septembre 2010 =E0 10:33 -0700, Jesse Gross a =E9crit =
:
>
>> The tx lock has another use here: to break local loops. =A0With this
>> change, a misconfigured tunnel can bring down the machine with a sta=
ck
>> overflow. =A0There are clearly other ways to fix this that don't req=
uire
>> a lock that restricts parallelism, such as a loop counter, but that'=
s
>> the way it is now.
>
> Thats a very good point !
>
> We could use a loop counter in the skb, but this use a bit of ram,
> or percpu counters in tunnel drivers, to avoid a given level of
> recursion.

I agree, a percpu loop counter is the way to go.  I implemented
something nearly identical to deal with this problem in Open vSwitch.

There are actually a number of optimizations in the Open vSwitch
tunneling stack that you may be interested in taking a look at as well
(for example, it has had this sort of lockless transmit for a while):

http://openvswitch.org/cgi-bin/gitweb.cgi?p=3Dopenvswitch;a=3Dblob;f=3D=
datapath/tunnel.c;hb=3DHEAD

The plan is to upstream all of the kernel code (or at least offer it),
just trying to get the userspace interfaces settled down first.
