From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Sat, 26 Apr 2014 12:02:28 +0900
Message-ID: <CAKD1Yr162yVuLcQ5B42a8ovvFj+BV4LBic29+qjAA7YDA0pN=w@mail.gmail.com>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
 <20140423153018.GA13717@breakpoint.cc> <1398268542.7767.145.camel@deadeye.wl.decadent.org.uk>
 <20140423162712.GB13717@breakpoint.cc> <20140424151748.GH1960@order.stressinduktion.org>
 <1398355320.7767.175.camel@deadeye.wl.decadent.org.uk> <20140424163712.GJ1960@order.stressinduktion.org>
 <CAKD1Yr0X5vqhdmFkwfgd0WJ0Jw7GGm8=iHNPeyfNKoODN4=1Mw@mail.gmail.com> <20140425211809.GC7050@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Lorenzo Colitti <lorenzo@google.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:48762 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbaDZDCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 23:02:50 -0400
Received: by mail-ig0-f176.google.com with SMTP id uy17so2911222igb.15
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 20:02:50 -0700 (PDT)
In-Reply-To: <20140425211809.GC7050@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 26, 2014 at 6:18 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>> One of the original discussion threads I posted above has a link to a
>> lengthy discussion on why the original designers of this code thought
>> capabilities were not a good idea from a security standpoint.
>
> Hmm, maybe I have overlooked it but I have not found any references to
> capabilities.

I thought I had linked to that, but perhaps I hadn't. This was
proposed for the first time in 2010:
http://thread.gmane.org/gmane.linux.kernel/1079723 . The discussion on
capabilities is linked a few messages down,
http://www.openwall.com/lists/oss-security/2010/11/08/3 .

> Ok, I see. There seem to be more users of this on Android. I guess ping
> sockets are available to every application writer or will it be set
> dynamically because of application permissions? Sorry, I am not that common
> with android.

Android sets ping_group_range to "allow everything". Access to general
network connectivity is restricted by Android application permissions,
so if an application has that, it can send pings.

> Ack, that's why my first hunch was to introduce a new capability just for ping
> sockets. I assume this wouldn't work for android?

Android userspace would need to be changed to use it (to give it to
everything that has network access permissions). I don't know if
there's a way to do that today.

Also, if you introduced a new capability for this, I think the 10KB
extra code would still be there. Because ping sockets don't allow you
to send/receive arbitrary ICMP messages, they only allow ping packets.
So "a new capability to allow ping" would have to be similarly
restricted, which means a lot of the code would still have to be
there.
