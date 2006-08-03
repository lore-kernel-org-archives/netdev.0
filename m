From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 5/6] htb: use hlist for hash lists.
Date: Thu, 3 Aug 2006 11:34:44 +0200
Message-ID: <20060803093444.GA2941@ff.dom.local>
References: <20060802150340.7faabd1d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:5610 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S932430AbWHCJc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 05:32:29 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060802150340.7faabd1d@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03-08-2006 00:03, Stephen Hemminger wrote:
...

Hi,

By the way, isn't htb supposed to recognize here ids 
got like this: tc filter add ... classid 0:1 
Some qdisc like prio do this and it is mentioned in
sch_api.c which is passing this without error code:

> @@ -220,12 +220,13 @@ #endif
>  static inline struct htb_class *htb_find(u32 handle, struct Qdisc *sch)
>  {
>  	struct htb_sched *q = qdisc_priv(sch);
> -	struct list_head *p;
> +	struct hlist_node *p;
> +	struct htb_class *cl;
> +
>  	if (TC_H_MAJ(handle) != sch->handle)
>  		return NULL;

I've tried this for example:

-	if (TC_H_MAJ(handle) != sch->handle) 
+	if (TC_H_MAJ(handle) == 0) /* 0:Y class is X:Y, where X:0 is qdisc */
+		handle += sch->handle;
+	else if (TC_H_MAJ(handle) != sch->handle)
 		return NULL;
 	
On the other hand I don't understand why it should be good
if there could be the real priority(from tos) only by accident
equal to the classid?

Jarek P.

