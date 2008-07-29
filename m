From: cpusoft <cpusoft@gmail.com>
Subject: where change events in epoll_wait(), and who notify an epoll event?
Date: Tue, 29 Jul 2008 09:54:35 +0800
Message-ID: <15da71430807281854v3e7c2536hd4e709a9a5dc7bb6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:19845 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbYG2Byg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 21:54:36 -0400
Received: by wr-out-0506.google.com with SMTP id 69so4111540wri.5
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 18:54:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi, group

i have question in epoll functions.
as we know, user can use poll_wait() as follows:
for(;;) {
 nfds = epoll_wait(kdpfd, events, maxevents, -1);
 for(n = 0; n < nfds; ++n) {
     do_my_function(events[n].data.fd);
 }
}
that means we can get the new events from the parameter events from
epoll_wait().

Then i search the kernel, and find the new events comes from
ep_send_events() finally , through sys_poll_wait() and ep_poll().
the ep_send_evnets() shows as follows:

static int ep_send_events(struct eventpoll *ep, struct epoll_event
                                      __user *events, int maxevents)
{
       ....
       //in here,  revents = POLLIN | POLLRDNORM;
       revents = epi->ffd.file->f_op->poll(epi->ffd.file, NULL);

      // i wonder where changes the epi->event.events??
       revents &= epi->event.events;
}

So, the revents comes from epi->event.events.

But, i wonder where changes the epi->event.events? and who notify the
epoll event ?
i find nothing from lxr.linux.no by search "event.evnets" as keyword.

Can anybody help me?
