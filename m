From: cpusoft <cpusoft@gmail.com>
Subject: Re: where change events in epoll_wait(), and who notify an epoll event?
Date: Tue, 29 Jul 2008 20:38:28 +0800
Message-ID: <15da71430807290538l6f702303hfa57665314c89ff1@mail.gmail.com>
References: <15da71430807281854v3e7c2536hd4e709a9a5dc7bb6@mail.gmail.com>
	 <20080729063909.GB7009@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:46095 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497AbYG2Mib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 08:38:31 -0400
Received: by wr-out-0506.google.com with SMTP id 69so4246926wri.5
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 05:38:29 -0700 (PDT)
In-Reply-To: <20080729063909.GB7009@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi:

> On Tue, Jul 29, 2008 at 2:39 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Hi.
>
> On Tue, Jul 29, 2008 at 09:54:35AM +0800, cpusoft (cpusoft@gmail.com) wrote:
>> But, i wonder where changes the epi->event.events? and who notify the
>> epoll event ?
>
> Nothing modifies events, only revents are used to specify mask of the
> condition.
>
> When new event is inserted into the epoll system, appropriate
> driver's (attached to the file's private data)->poll() callback is
> invoked. When the last parameter is non-NULL, it specifies essentially
> the wait queue to attach to the private wait queue head of the driver.
> When driver triggers some condition and calls
> wake_up(&private_wait_queue_head),

thanks alot. however, i still  wonder who call the driever's
wake_up(&private_wait_queue_head)?

i find when  ethernet card receive a packet from internet, it will
call net_interupt(), then call net_rx() and call netif_rx(), but i
cannot find it next call what function.
( function  is in : http://lxr.linux.no/linux+v2.6.26/net/core/netpoll.c#L533 )
void netif_rx(){
  np->rx_hook(np, ntohs(uh->source),    (char *)(uh+1),   ulen -
sizeof(struct udphdr));
}
struct netpoll {
    void (*rx_hook)(struct netpoll *, int, char *, int);
};
but i cannot find the (*rx_hook) point to which function? such as
struct netpoll np{
   .rx_hook = ???
}
So, i wonder,
first is it the right way to call wake_up(&private_wait_queue_head)?
and which function is the real (*rx_hook) ?

please help me.
thank u.


> all wait queues attached there are
> processed and callback stored in each one is executed. Callback for
> epoll's wait queue puts given event into the ready list and wakes up
> epoll_wait(), which copies data to userspace.
>
> --
>        Evgeniy Polyakov
>
