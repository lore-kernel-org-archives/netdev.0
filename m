From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Thu, 10 Aug 2006 19:51:20 +0400
Message-ID: <20060810155120.GA494@ms2.inr.ac.ru>
References: <20060809204821.216122988@postel.suug.ch> <20060809205439.434010049@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:34021 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1161363AbWHJPwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 11:52:02 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060809205439.434010049@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> This patch handles NLM_F_ECHO in netlink_rcv_skb() to
> handle it in a central point. Most subsystems currently
> interpret NLM_F_ECHO as to just unicast events to the
> originator of the change while the real meaning of the
> flag is to echo the request.

Do not you think it is useless to echo something back to originator,
who just sent it?

Actually, the sense of NLM_F_ECHO was to tell user what happened due to
his request. The answer is not original request, which can contain
some incomplete fields etc., but full information about object
deleted/added/changed. Moreover, the feedback can contain several
messages (though accurately it is done only in net/sched/), f.e. when
the request triggered deletion of one object and addition of another.

Obviously, it cannot be done in a central place.

Normally, it is not needed, "ip route add" does not tell user, what
actually was done, so that it suppresses echo. But for multistage
operation it is absolutely necessary: the answer contains f.e. auto-allocated
handles, which should be given in subsequent requests.

Alexey
