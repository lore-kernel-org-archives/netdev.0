From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] filter: added BPF random opcode
Date: Fri, 18 Apr 2014 13:21:35 -0700
Message-ID: <CAMEtUuxb0PDU5mJVjajGZNwaCAt=5xTj4tyH99_LWRstzQTtUw@mail.gmail.com>
References: <1397585816-1267-1-git-send-email-chema@google.com>
	<CAMEtUuw3-LEuwJ2cAQ+F-tu_-wzy4HK4ZteAuJpYfY9hW66+FA@mail.gmail.com>
	<1397698696.4222.138.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chema Gonzalez <chema@google.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:58661 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaDRUVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 16:21:37 -0400
Received: by mail-we0-f175.google.com with SMTP id q58so1875119wes.6
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2014 13:21:36 -0700 (PDT)
In-Reply-To: <1397698696.4222.138.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2014 at 6:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-04-15 at 23:24 -0700, Alexei Starovoitov wrote:
>
>> In particular I don't find the reason of moving random
>> packet sampling into kernel to be that great.
>> pcap cannot receive them quickly enough anyway,
>> so there are drops already.
>> Just randomly pick packets that reached the user space.
>> Why add this to the kernel? I don't see how it can improve accuracy.
>
> It has nothing to do with speed or accuracy.
>
> Being able to intercept 0.001 % of the packets (and not 0.001 % of the
> flows...) can be useful to network operators.
>
> _Then_ if its super super super fast, thats better, of course.
>
> Suggesting to intercept all packets, then filtering 99.999 % of them in
> user space is not going to work. Its going to be super super super slow.

correct.
I was suggesting user space approach, because example does:
+  ld rand
+  mod #4
+  jneq #1, drop

If 4 is replaced with rate of packets per second and which can be
roughly estimated before creating the filter, then this example would
make sense.
On a loaded server the rate will be in tens of millions, but when it idles
this fixed rand()%1000000==1 won't be sending anything to
userspace for hours.

I suspect adding 'ld rand' just 'felt' useful and no real
filters were created with it.
For true packet sampling 'ld getnstime' would be needed too.
As I said I like the approach, I just want to see a real use case for it.
