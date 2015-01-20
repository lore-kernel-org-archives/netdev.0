From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/2] bnx2x: fix napi poll return value for repoll
Date: Tue, 20 Jan 2015 06:54:04 -0800
Message-ID: <1421765644.4832.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421759776-376-1-git-send-email-_govind@gmx.com>
	 <1421759776-376-3-git-send-email-_govind@gmx.com>
	 <1421765480.4832.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ariel.elior@qlogic.com, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:38009 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548AbbATOyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:54:07 -0500
Received: by mail-pd0-f182.google.com with SMTP id z10so3991600pdj.13
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 06:54:07 -0800 (PST)
In-Reply-To: <1421765480.4832.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-20 at 06:51 -0800, Eric Dumazet wrote:

> >  
> >  		for_each_cos_in_tx_queue(fp, cos)
> >  			if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
> > @@ -3187,7 +3187,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
> >  			/* must not complete if we consumed full budget */
> >  			if (work_done >= budget) {
> >  				bnx2x_fp_unlock_napi(fp);
> > -				break;
> > +				return budget;
> 
> This one looks fine.

But its not necessary, as here budget == work_done.

(work_done > budget) would be a bug from bnx2x_rx_int()
