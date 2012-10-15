From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Mon, 15 Oct 2012 11:25:36 +0200
Message-ID: <1350293136.21172.17527.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
	 <1350246414.21172.17144.camel@edumazet-glaptop>
	 <1350246481.21172.17147.camel@edumazet-glaptop>
	 <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
	 <1350248858.21172.17197.camel@edumazet-glaptop>
	 <CAO_aot6w9yaWacK9kE66m+Lv0LWXY9hKzLH8b=1dp=23fo_W2A@mail.gmail.com>
	 <1350250542.21172.17229.camel@edumazet-glaptop>
	 <CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
	 <1350252091.21172.17257.camel@edumazet-glaptop>
	 <CAO_aot6j2TPe9yxnA1ktMQsfnnWF1XwmCrQUmCcfOqCqbc6dZA@mail.gmail.com>
	 <1350279753.21172.17290.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:61166 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681Ab2JOJZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 05:25:41 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so3299629lbo.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 02:25:40 -0700 (PDT)
In-Reply-To: <1350279753.21172.17290.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-15 at 07:42 +0200, Eric Dumazet wrote:
> On Mon, 2012-10-15 at 00:11 +0200, Jan Hinnerk Stosch wrote:
> > 2012/10/15 Eric Dumazet <eric.dumazet@gmail.com>:
> > > Please add -f to follow children
> > >
> > > strace -o /tmp/STRACE -f /usr/bin/ntpd -g -u ntp:ntp
> > >
> > >
> > 
> > Ok, done.
> 
> # grep bind STRACE
> 
> 
> 
> 12928 bind(16, {sa_family=AF_INET, sin_port=htons(123), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
> 12928 bind(17, {sa_family=AF_INET6, sin6_port=htons(123), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0
> 
> (These two binds are the wildcards to drop ipv4/ipv6 packets sent on other addresses than
>  the following :)
> 
> 12928 bind(18, {sa_family=AF_INET, sin_port=htons(123), sin_addr=inet_addr("127.0.0.1")}, 16) = 0
> 12928 bind(19, {sa_family=AF_INET, sin_port=htons(123), sin_addr=inet_addr("192.168.178.27")}, 16) = 0
> 12928 bind(20, {sa_family=AF_INET6, sin6_port=htons(123), inet_pton(AF_INET6, "fe80::922b:34ff:fe33:c292", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=if_nametoindex("eth0")}, 28) = 0
> 12928 bind(21, {sa_family=AF_NETLINK, pid=0, groups=00000771}, 12) = 0
> 
> So ntpd doesnt listen on ntp messages sent on ::1
> 
> 

Hmm, another strange thing in your STRACE file is :


12928 open("/proc/net/if_inet6", O_RDONLY) = 6
12928 fstat(6, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
12928 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
-1, 0) = 0x7fc54a719000
12928 lseek(6, 0, SEEK_SET)             = 0
12928 read(6, "fe80000000000000922b34fffe33c292"..., 1024) = 54


So /proc/net/if_inet6 doesnt include lo device on your machine ?
