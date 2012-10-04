From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tipc: flow control should not account for sk_rcvbuf
Date: Thu, 04 Oct 2012 12:26:00 +0200
Message-ID: <1349346360.16011.36.camel@edumazet-glaptop>
References: <1349342067-27586-1-git-send-email-erik.hugne@ericsson.com>
	 <1349342493.16011.32.camel@edumazet-glaptop>
	 <506D5DEF.9050700@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jon Maloy <jon.maloy@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44674 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001Ab2JDK0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 06:26:06 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so188489bkc.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 03:26:04 -0700 (PDT)
In-Reply-To: <506D5DEF.9050700@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-04 at 11:59 +0200, Erik Hugne wrote:
> > What guarantee do we have this cannot use all kernel memory ?
> >
> > If sk->sk_rcvbuf is not an acceptable limit here, you must use a
> > different limit, but not infinity.
> >
> There is an implicit limit on how much data that can be buffered on each 
> socket, controlled by TIPC_FLOW_CONTROL_WIN.
> 
> This limit is:
> TIPC_FLOW_CONTROL_WIN * 2 * TIPC_MAX_USER_MSG_SIZE

And this limit is tested _before_ queueing to backlog if socket is owned
by the user ?

You'll have to demonstrate this in the changelog.

Again, I dont think this patch is safe, we need an explicit limit.
