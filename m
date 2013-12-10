From: ajay seshadri <seshajay@gmail.com>
Subject: Re: Fwd: UDP/IPv6 performance issue
Date: Tue, 10 Dec 2013 14:46:19 -0500
Message-ID: <CAGA2gK5pxQXAxgffYgitWg9jUUkxnz7EEhjQZ2aSvgnWFyR9RQ@mail.gmail.com>
References: <CAGA2gK6rf8E7cCO=RwbdFAt2ucfxUbCjqhVoga9cnHrEKxcp9g@mail.gmail.com>
	<CAGA2gK5gfdaKeQWzT4Dd45AhavD4pYaCVyayf7Hd+q5pPUjfKQ@mail.gmail.com>
	<20131210171248.GA23216@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: ajay seshadri <seshajay@gmail.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:61179 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036Ab3LJTqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 14:46:20 -0500
Received: by mail-ie0-f179.google.com with SMTP id x13so9115203ief.24
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 11:46:19 -0800 (PST)
In-Reply-To: <20131210171248.GA23216@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Dec 10, 2013 at 12:12 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> IPv6 Routing code is not as well optimized as the IPv4 one. But it is
> strange to see fib6_force_start_gc() to be that high in perf top.
>
> I guess you are sending the frames to distinct destinations each time? A
> cached entry is created on each send in the fib and as soon as the maximum of
> 4096 is reached a gc is forced. This setting is tunable in
> /proc/sys/net/ipv6/route/max_size.

My sender is connected to just one other system. My management
interfaces use IPv4 addresses. Only the data path has IPv6 addresses.
So, the IPv6 route cache always has only one entry for the
destination. This eliminates the possibility of exceeding the
capacity(4096). Even I was surprised to see fib6_force_start_gc().

> A cached entry will be inserted nontheless. If you don't hit the max_size
> route entries limit I guess there could be a bug which triggers needless gc
> invocation.

I am leaning towards needless invocation of gc. At this point in time,
I am not sure why.

> Could you send me your send pattern so maybe I could try to reproduce it?

For netperf i use:
./netperf -t UDP_STREAM -H <remote> -l 60 -- -m 1450
If that answers your question. I am not trying to download any file of
a specific type.

As a side note,
ipv6_get_saddr_eval() used to show up right at the top of the "perf
top" profile using the most CPU cycles (especially when I had multiple
global IPv6 addresses). I was able to get rid of it by binding the
socket to the corresponding source address at the sender. If the
sender side socket is bound to in6addr_any or we don't bind it
explicitly as in most cases for UDP, for every extra global address I
configure on the interface, I take a performance hit. I am wondering
if the source address look up code is not optimized enough.

Thanks,
Ajay
