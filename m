From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 11 Feb 2008 23:49:24 +0100
Message-ID: <20080211224924.GA2863@ami.dom.local>
References: <200802110922.m1B9MKQ4003674@quickie.katalix.com> <47B09A90.7040508@gmail.com> <47B0C9F7.5040200@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:29059 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758741AbYBKWo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 17:44:26 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1326935nfb.21
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 14:44:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47B0C9F7.5040200@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2008 at 10:19:35PM +0000, James Chapman wrote:
...
> Below is example output from lockdep. The oops is reproducible when  
> creating/deleting lots of sessions while passing data. The lock is being  
> acquired for read and write in softirq contexts.
>
> Is there a better way to fix this?
>
> =================================
> [ INFO: inconsistent lock state ]
> 2.6.24-core2 #1
> ---------------------------------
> inconsistent {in-softirq-R} -> {softirq-on-W} usage.
> openl2tpd/3215 [HC0[0]:SC0[0]:HE1:SE1] takes:
>   (&tunnel->hlist_lock){---?}, at: [<f8eea157>]
> pppol2tp_connect+0x517/0x6d0 [pppol2tp]
> {in-softirq-R} state was registered at:

IMHO, according to this, disabling bh should be enough. And if it's
like in this report: only read_lock is taken from softirqs, then this
should be necessary to change only all write_locks to write_lock_bh
(of course unless somewhere bhs are disabled already). Unless I miss
something?!

Cheers,
Jarek P.
