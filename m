From: "pradeep singh" <pradeep.rautela@gmail.com>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer dereferencing
Date: Thu, 21 Jun 2007 18:12:49 +0530
Message-ID: <a901b49a0706210542y1a602466of56d1897c38e45c2@mail.gmail.com>
References: <a901b49a0706210500g43a4c4a5y19c9ddbd83a50828@mail.gmail.com>
	 <20070621120358.GK18863@kernel.dk>
	 <a901b49a0706210511l786196c8n4d5d0a084705d51c@mail.gmail.com>
	 <20070621123414.GL18863@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, jgarzik@pobox.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: "Jens Axboe" <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:27822 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024AbXFUMmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 08:42:50 -0400
Received: by nz-out-0506.google.com with SMTP id n1so580850nzf
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2007 05:42:50 -0700 (PDT)
In-Reply-To: <20070621123414.GL18863@kernel.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/21/07, Jens Axboe <jens.axboe@oracle.com> wrote:
> On Thu, Jun 21 2007, pradeep singh wrote:
> > Hi
> > On 6/21/07, Jens Axboe <jens.axboe@oracle.com> wrote:
> > >On Thu, Jun 21 2007, pradeep singh wrote:
> > >> Hi,
> > >>
> > >> Chelsio's in kernel 10G driver does not checks the return value from
> > >> t1_get_board_info() in cxgb2.c.
> > >> t1_get_board_info may return a NULL and we still go on to dereference
> > >> it in the for loop without checking for the NULL.
> > >>
> > >> This patch fixes this.
> > >
> > >Patch looks odd - bi is dereferenced a number of times after that loop
> > >anyway, so I don't see your patch fixing much.
> > Thanks for pointing that out Jens.
> > Sorry, i pushed it in a haste :(.
> > Will check again and resubmit it.
>
> You're welcome. The first thing to do is analyze whether a NULL return
> from t1_get_board_info() makes any sense. From a quick look, driver_data
> should be the index into the t1 pci table. So if t1_get_board_info()
> returns NULL, it must be some core bug. So I'd say either don't handle
> it, or mark it with BUG_ON(), or do the !bi check and CH_ERR() a warning
> and goto out_disable_pdev.
Thanks for the advice Jens :).

Yeah this is what i am doing right now.
Will resubmit the patch.

Thanks a lot.
--pradeep
>
> --
> Jens Axboe
>
>


-- 
Pradeep
