From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Mon, 8 Nov 2004 19:33:00 +0100
Message-ID: <20041108183300.GF31969@postel.suug.ch>
References: <418B4C7C.8000402@crocom.com.pl> <418EA032.7050507@trash.net> <418ECE85.9090203@trash.net> <20041108135431.GE31969@postel.suug.ch> <418F9AD0.1040701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Szymon Miotk <spam@crocom.com.pl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <418F9AD0.1040701@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <418F9AD0.1040701@trash.net> 2004-11-08 17:12
> Thomas Graf wrote:
> 
> >>+	/* unlink inner qdiscs from dev->qdisc_list immediately */
> >>+	if (qdisc->ops->cl_ops != NULL)
> >>+		list_add(&qdisc->list, &cql);
> >>   
> >>
> >
> >I think you should extend the above to:
> >
> >if (qdisc->ops->cl_ops != NULL && !list_empty(&qdisc->list))
> >
> >Otherwise you might unlink entries just added before the
> >rcu callback and it prevents an unneeded attempt to delete
> >qdiscs for inner classful qdiscs
> > 
> >
> There is some optimization possible, I will do this for the final
> patch. But I don't understand the problem you refer to, can you
> please explain ?

I don't have the time to verify this at the moment but:

1) qdisc_destroy unlinking all the lists
2) RTM_NEWQDISC creating a new qdisc with the same major classid as the old one
   which will suceed since the old one cannot be found anymore.
3) rcu callback __qdisc_destroy -> qdisc_destroy looking through qdisc_list
   again and then deleting the new entries because their major classid matches.

I might be missing something though.
