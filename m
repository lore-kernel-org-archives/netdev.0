From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Sun, 7 Nov 2004 20:08:41 +0100
Message-ID: <20041107190841.GD31969@postel.suug.ch>
References: <418C2D40.9020300@trash.net> <20041106015931.GA28715@postel.suug.ch> <20041106145036.GB28715@postel.suug.ch> <418DE37E.2050504@trash.net> <20041107140015.GA31969@postel.suug.ch> <418E4B2E.1070407@trash.net> <20041107163330.GB31969@postel.suug.ch> <418E553C.2070006@trash.net> <20041107174909.GC31969@postel.suug.ch> <418E67D0.8010301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <418E67D0.8010301@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >Anyways, I do think we should force the task to be completed, or
> >at least all the list unlinking, before the rtnl semaphore is given
> >back.  I'm fine with postponing the deletion of the object but not
> >to postpone list manipulations even if we cannot reproduce it now.
> 
> This is what I'm doing now, your patch to set qdisc->parent makes
> this very easy :) Simply remove all qdiscs with
> (TC_H_MAJ(q->parent) == TC_H_MAJ(qdisc->handle)) from
> dev->qdisc_list when a classful qdisc is destroyed.

Great, that's even better, speeds up deletion of big class
trees. Thanks.
