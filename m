From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Mon, 8 Nov 2004 14:54:31 +0100
Message-ID: <20041108135431.GE31969@postel.suug.ch>
References: <418B4C7C.8000402@crocom.com.pl> <418EA032.7050507@trash.net> <418ECE85.9090203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Szymon Miotk <spam@crocom.com.pl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <418ECE85.9090203@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> +	/* unlink inner qdiscs from dev->qdisc_list immediately */
> +	if (qdisc->ops->cl_ops != NULL)
> +		list_add(&qdisc->list, &cql);

I think you should extend the above to:

if (qdisc->ops->cl_ops != NULL && !list_empty(&qdisc->list))

Otherwise you might unlink entries just added before the
rcu callback and it prevents an unneeded attempt to delete
qdiscs for inner classful qdiscs

Otherwise the patch looks very good.
