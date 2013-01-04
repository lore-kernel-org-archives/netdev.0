From: Tom Herbert <therbert@google.com>
Subject: Re: UDP multi-core performance on a single socket and SO_REUSEPORT
Date: Fri, 4 Jan 2013 12:47:04 -0800
Message-ID: <CA+mtBx_+xR5Y5zEn6nxQ=++FEWKUw+zHzP4MamM_EEF-mMXB1Q@mail.gmail.com>
References: <50DD6DF1.7080304@markandruth.co.uk>
	<50E72493.4050406@markandruth.co.uk>
	<1357328238.1678.2189.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mark Zealey <netdev@markandruth.co.uk>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:60005 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749Ab3ADUrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 15:47:06 -0500
Received: by mail-ie0-f171.google.com with SMTP id 17so20240602iea.16
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 12:47:06 -0800 (PST)
In-Reply-To: <1357328238.1678.2189.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe the hard part of making SO_REUSEPORT was on the TCP side in
dealing with state in req structs which we have not resolved.  UDP
SO_REUSEPORT seems to be working pretty well.

Tom

On Fri, Jan 4, 2013 at 11:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-01-04 at 18:50 +0000, Mark Zealey wrote:
>> I have written two small test scripts now which can be found at
>> http://mark.zealey.org/uploads/ - one launches 16 listening threads for
>> a single UDP socket, the other needs to be run as
>>
>> for i in `seq 16`; do ./udp_test_client & done
>>
>> On my test server (32-core), stock kernel 3.7.1, 90% of the time is
>> spent in the kernel waiting on spinlocks. Perf output:
>
> Mark
>
> We know the scalability issue of using a single socket and many threads.
>
> The send path was somehow fixed to not require socket lock.
>
> But the receive path uses a single receive_queue, protected by a
> spinlock.
>
> SO_REUSEPORT would be nice, but had known issues.
>
> af_packet fanout implementation was nicer.
> You could try :
>
> 1) Use af_packet FANOUT instead of UDP sockets
>
> 2) rewrite SO_REUSEPORT to use a FANOUT like implementation
>
> 3) Extend UDP sockets to be able to use a configurable number of receive
> queues instead of a single one.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
