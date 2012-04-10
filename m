From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: restore correct limit
Date: Tue, 10 Apr 2012 12:40:36 +0200
Message-ID: <1334054436.3126.80.camel@edumazet-glaptop>
References: <4F83EB0E.4020104@monstr.eu>
	 <1334046444.3126.12.camel@edumazet-glaptop>
	 <1334046746.3126.13.camel@edumazet-glaptop>  <4F83F166.4010208@monstr.eu>
	 <1334047544.3126.14.camel@edumazet-glaptop>  <4F83F959.3070302@monstr.eu>
	 <1334049896.3126.23.camel@edumazet-glaptop>  <4F83FD7A.5010602@monstr.eu>
	 <1334050698.3126.30.camel@edumazet-glaptop>
	 <1334052194.3126.66.camel@edumazet-glaptop> <4F8407F7.8070703@monstr.eu>
	 <4F840B99.8040409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: monstr@monstr.eu, netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33093 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab2DJKkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 06:40:42 -0400
Received: by bkcik5 with SMTP id ik5so4067955bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 03:40:41 -0700 (PDT)
In-Reply-To: <4F840B99.8040409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 18:29 +0800, Jason Wang wrote:
> On 04/10/2012 06:14 PM, Michal Simek wrote:
> > On 04/10/2012 12:03 PM, Eric Dumazet wrote:
> >> Commit c43b874d5d714f (tcp: properly initialize tcp memory limits)
> >> added a regression on machines with low amount of memory, since sockets
> >> cant use 1/128 of memory but 1/1024
> >>
> >> Fix this to match comment and previous behavior.
> >>
> >> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> >> Cc: Jason Wang<jasowang@redhat.com>
> >> Cc: Glauber Costa<glommer@parallels.com>
> >> ---
> >>   net/ipv4/tcp.c |    2 +-
> >>   1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> >> index 5d54ed3..67d726e 100644
> >> --- a/net/ipv4/tcp.c
> >> +++ b/net/ipv4/tcp.c
> >> @@ -3302,7 +3302,7 @@ void __init tcp_init(void)
> >>
> >>       tcp_init_mem(&init_net);
> >>       /* Set per-socket limits to no more than 1/128 the pressure 
> >> threshold */
> >> -    limit = nr_free_buffer_pages()<<  (PAGE_SHIFT - 10);
> >> +    limit = nr_free_buffer_pages()<<  (PAGE_SHIFT - 7);
> >>       limit = max(limit, 128UL);
> >>       max_share = min(4UL*1024*1024, limit);
> >>
> >
> > hw design with csum is also much better.
> > Tested-by: Michal Simek <monstr@monstr.eu>
> >
> > Thanks for help,
> > Michal
> >
> >
> >
> >
> >
> Hi Michal and Eric:
> 
> Which version of kernel did you test, did you try the newest kernel? The 
> reason I use (PAGE_SHIFT - 10) is in the commit before 3dc43e3, the 
> limit were calculated with:
> 
>      limit = nr_free_buffer_pages() / 8;
>      limit = max(limit, 128UL);
> ...
>      limit = ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT - 7);
> 
> So the rmem should be ok. But there's a defect (which I think does 
> affect the regression) of my patch would could cause limit that we 
> should shift after comparing with 128UL like:
> 
>      limit = nr_free_buffer_pages() / 8;
>      limit = max(limit, 128UL) << (PAGE_SHIFT - 7);
> 
> Is anything I miss?
> 

Yes, probably.

Maybe you should check what was the situation on 2.6 kernels.

Your commit did not completely fix the 4acb41903b2 one

I dont feel its necessary to put in the changelog the complete bug
history, since your commit does the needed tracking.
