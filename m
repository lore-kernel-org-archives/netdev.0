From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED] cls_basic: Use unsigned int when generating handle
Date: Tue, 26 Sep 2006 15:32:04 +0200
Message-ID: <45192BD4.9030702@trash.net>
References: <20060926115910.GV18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kim.nordlund@nokia.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:26600 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751373AbWIZNf2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 09:35:28 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060926115910.GV18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Prevents filters from being added if the first generated
> handle already exists.
> 
> Signed-off-by: Kim Nordlund <kim.nordlund@nokia.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Index: net-2.6/net/sched/cls_basic.c
> ===================================================================
> --- net-2.6.orig/net/sched/cls_basic.c	2006-09-26 13:35:29.000000000 +0200
> +++ net-2.6/net/sched/cls_basic.c	2006-09-26 13:35:39.000000000 +0200
> @@ -194,7 +194,7 @@
>  	if (handle)
>  		f->handle = handle;
>  	else {
> -		int i = 0x80000000;
> +		unsigned int i = 0x80000000;

I don't see how this patch changes anything, the loop already
ends when i == 0 (and it can't go negative):

        do {
                if (++head->hgenerator == 0x7FFFFFFF)
                        head->hgenerator = 1;
        } while (--i > 0 && basic_get(tp, head->hgenerator));

which should also make sure that no handle gets used twice:

        if (i <= 0) {
                printk(KERN_ERR "Insufficient number of handles\n");
                goto errout;
        }
