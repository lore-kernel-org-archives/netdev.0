From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] tcp: add TCP_CC_INFO socket option
Date: Wed, 29 Apr 2015 04:07:05 -0700
Message-ID: <1430305625.3711.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430263429-4069-1-git-send-email-edumazet@google.com>
	 <1430263429-4069-3-git-send-email-edumazet@google.com>
	 <55409393.3040003@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35943 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422735AbbD2LHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 07:07:08 -0400
Received: by pdea3 with SMTP id a3so25206819pde.3
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 04:07:07 -0700 (PDT)
In-Reply-To: <55409393.3040003@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-29 at 10:17 +0200, Daniel Borkmann wrote:
> On 04/29/2015 01:23 AM, Eric Dumazet wrote:
> > Some Congestion Control modules can provide per flow information,
> > but current way to get this information is to use netlink.
> >
> > Like TCP_INFO, let's add TCP_CC_INFO so that applications can
> > issue a getsockopt() if they have a socket file descriptor,
> > instead of playing complex netlink games.
> >
> > Sample usage would be :
> >
> >    union tcp_cc_info info;
> >    socklen_t len = sizeof(info);
> >
> >    if (getsockopt(fd, SOL_TCP, TCP_CC_INFO, &info, &len) == -1)
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Yuchung Cheng <ycheng@google.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> 
> Presuming other cc algorithms would in future also export
> internal information through this interface, would it make
> sense to put tcp_cc_info into a container structure so we
> don't miss out attr (vegas, dctcp, ...), like:
> 
>    struct tcp_cc_exp {
>      u32               kind;
>      union tcp_cc_info info;
>    };
> 
> Otherwise looks good:
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

I thought of this, but I really believe this is not needed, as the
application can already fetch CC name (if really its does not know yet)

And I also wanted to get same layout for info provided by netlink and
getsockopt()

Thanks !
