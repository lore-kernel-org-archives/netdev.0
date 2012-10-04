From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tipc: flow control should not account for sk_rcvbuf
Date: Thu, 04 Oct 2012 15:55:13 +0200
Message-ID: <1349358913.16011.59.camel@edumazet-glaptop>
References: <1349342067-27586-1-git-send-email-erik.hugne@ericsson.com>
	 <1349342493.16011.32.camel@edumazet-glaptop>
	 <506D5DEF.9050700@ericsson.com>
	 <1349346360.16011.36.camel@edumazet-glaptop>
	 <506D7D24.3070601@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jon Maloy <jon.maloy@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56088 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933102Ab2JDNzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 09:55:19 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so325267bkc.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 06:55:18 -0700 (PDT)
In-Reply-To: <506D7D24.3070601@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-04 at 14:12 +0200, Erik Hugne wrote:
> > And this limit is tested _before_ queueing to backlog if socket is owned
> > by the user ?
> >
> > You'll have to demonstrate this in the changelog.
> >
> > Again, I dont think this patch is safe, we need an explicit limit.
> You're right Eric..
> 
> Another way of solving it is to increase the default sk_rcvbuf size to
> (TIPC_FLOW_CONTROL_WIN * 2 * TIPC_MAX_USER_MSG_SIZE)
> at socket creation.
> 
> Do you think that would be acceptable?
> 

If its a tipc constant, you also could use

if (sk_add_backlog(sk, buf,
                   TIPC_FLOW_CONTROL_WIN * 2 * TIPC_MAX_USER_MSG_SIZE))

no ?

But yes, a protocol is allowed to change sk_rcvbuf value (its done for
TCP for example, with a limit to tcp_rmem[2] (between 4 and 6 Mbytes)
