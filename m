From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: epoll, missed opportunity?
Date: Sat, 19 Sep 2015 08:21:58 -0700
Message-ID: <1442676118.29850.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACKT+AqSZS+o-C2osio7PWy+2bKuveT-uU2znSOHBjNRKxc0-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jonathan Marler <johnnymarler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33526 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867AbbISPWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 11:22:00 -0400
Received: by pacex6 with SMTP id ex6so76733929pac.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 08:21:59 -0700 (PDT)
In-Reply-To: <CACKT+AqSZS+o-C2osio7PWy+2bKuveT-uU2znSOHBjNRKxc0-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-09-18 at 22:51 -0600, Jonathan Marler wrote:
> I'm curious why there wasn't another field added to the epoll_event
> struct for the application to store the descriptor's context. Any
> useful multi-plexing application will have a context that will need to
> be retrieved every time a descriptor needs to be serviced. Since the
> epoll api has no way of storing this context, it has to be looked up
> using the descriptor, which will take more time/memory as the number
> of descriptors increase. The memory saved from omitting this context
> can't be worth it since you'll have to allocate the memory in the
> application anyway, plus you're now adding the extra lookup.
> 
> This "lookup" problem has always existed in multi-plexed applications.
> It was impossible to fix with older polling interfaces, however, since
> epoll is stateful, it provides an opportunity to fix this problem by
> storing the descriptor context in epoll's "state". What was the reason
> for not doing this?  Was it an oversight or am I missing something?


typedef union epoll_data
{
  void *ptr;
  int fd;
  uint32_t u32;
  uint64_t u64;
} epoll_data_t;

struct epoll_event
{
  uint32_t events;      /* Epoll events */
  epoll_data_t data;    /* User data variable */
} __EPOLL_PACKED;



Application is free to use whatever is needed in poll_data_t

You can store a pointer to your own data (ptr)
Or a 32 bit cookie (u32)
Or a 64 bit cookie (u64)

(But is an union, you have to pick one of them)

Nothing forces you to use 'fd', kernel does not care.
