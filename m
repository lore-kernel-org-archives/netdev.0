From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] PKT_SCHED: Fix double locking in tcindex destroy path
Date: Fri, 10 Dec 2004 03:35:45 +0100
Message-ID: <41B90B81.1020102@trash.net>
References: <20041210014918.GT1371@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041210014918.GT1371@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>tcindex's destroy uses its own delete functions to destroy its
>configuration. The delete function (correctly) takes the qdisc_tree_lock
>to prevent list walkings from happening while removing from the list.
>The qdisc_tree_lock is already held if we're comming via the destroy
>path and thus a double locking takes place.
>
>Patch not needed for 2.4 since both destroy paths are unlocked but will
>be needed if we add them.
>  
>
Looks correct, but 2.4 does need this. qdisc_destroy in 2.4 always
happens under dev->queue_lock. For example dev_shutdown from 2.4:

        write_lock(&qdisc_tree_lock);
        spin_lock_bh(&dev->queue_lock);
...
        qdisc_destroy(qdisc);

But please rename "already_locked" to "lock" to make it look less like
a hack to avoid deadlock.

>+	return __tcindex_delete(tp,arg, 1);
>  
>
And a space is missing :)

Regards
Patrick
