From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v3 0/3] net: reserve ports for applications using fixed port numbers
Date: Mon, 15 Feb 2010 14:37:36 +0200
Message-ID: <201002151437.36948.opurdila@ixiacom.com>
References: <1265854160-11763-1-git-send-email-opurdila@ixiacom.com> <4B794082.1070004@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:15231 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751466Ab0BOMlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 07:41:09 -0500
In-Reply-To: <4B794082.1070004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 15 February 2010 14:39:30 you wrote:
> Octavian Purdila wrote:
> > This patch series is based on Amerigo's v2 but it now uses a bitmap
> > for port reservation.
> >
> > I've ran a while (1) { bind(0) } test (with ip_local_port_range
> > 1024 65000) to see if there is any performance difference between the
> > two approaches (ranges vs bitmap). I could not detect any significant
> > difference, both cases scored in 2.76s +/- 0.01 on my setup.
> >
> > I've based this patch series on current net-next, but it contains a
> > significant non networking part. Please let me know if I should handle
> > this differently.
> >
> > Octavian Purdila (3):
> >   sysctl: refactor integer handling proc code
> >   sysctl: add proc_dobitmap
> >   net: reserve ports for applications using fixed port numbers
> >
> >  Documentation/networking/ip-sysctl.txt |   12 +
> >  drivers/infiniband/core/cma.c          |    7 +-
> >  include/linux/sysctl.h                 |    2 +
> >  include/net/ip.h                       |    6 +
> >  kernel/sysctl.c                        |  374
> > +++++++++++++++++++------------- net/ipv4/inet_connection_sock.c        |
> >    5 +
> >  net/ipv4/inet_hashtables.c             |    2 +
> >  net/ipv4/sysctl_net_ipv4.c             |    7 +
> >  net/ipv4/udp.c                         |    3 +-
> >  net/sctp/socket.c                      |    2 +
> >  10 files changed, 264 insertions(+), 156 deletions(-)
> 
> Hey, Octavian, typo in netdev list name...
> 
> Could you please fix it and resend? So that this will get more reviews.
> 

Sorry for that. I've already spotted it and resent it. I plan to send a new 
take end of this day (GMT + 2) which will also address Eric's comments by 
allocating the bitmap at init time.

Thanks,
tavi
