From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/4] tcp: better smp listener behavior
Date: Fri, 09 Oct 2015 07:49:16 -0700
Message-ID: <1444402156.27760.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
	 <CALx6S35NOaLyqmWbgcRdV9Swm1NVVSFkoShW0ywMi7V21jhtYQ@mail.gmail.com>
	 <1444387845.27760.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1444400998.27760.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tobias Klauser <tklauser@distanz.ch>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33823 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859AbbJIOtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 10:49:17 -0400
Received: by padhy16 with SMTP id hy16so88721817pad.1
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 07:49:17 -0700 (PDT)
In-Reply-To: <1444400998.27760.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-09 at 07:29 -0700, Eric Dumazet wrote:

> So the answer is : about 800,000 SYN per second in IPV6 with purely DDOS attack

My IPv6 routing setup was a bit silly ;)

With a slightly better one, we reach 3.8 Mpps and kernel profile looks
like :

    21.22%  [kernel]  [k] ip6_pol_route.isra.47      
    11.42%  [kernel]  [k] _raw_read_lock_bh          
     9.83%  [kernel]  [k] fib6_lookup                
     8.96%  [kernel]  [k] _raw_read_unlock_bh        
     8.47%  [kernel]  [k] fib6_get_table             
     4.01%  [kernel]  [k] __inet6_lookup_established 
     2.94%  [kernel]  [k] memcpy_erms                
     2.36%  [kernel]  [k] dst_release                
