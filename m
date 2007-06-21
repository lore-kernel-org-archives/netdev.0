From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer dereferencing
Date: Thu, 21 Jun 2007 14:34:16 +0200
Message-ID: <20070621123414.GL18863@kernel.dk>
References: <a901b49a0706210500g43a4c4a5y19c9ddbd83a50828@mail.gmail.com> <20070621120358.GK18863@kernel.dk> <a901b49a0706210511l786196c8n4d5d0a084705d51c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trivial@kernel.org, jgarzik@pobox.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: pradeep singh <pradeep.rautela@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:6127 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754643AbXFUMfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 08:35:06 -0400
Content-Disposition: inline
In-Reply-To: <a901b49a0706210511l786196c8n4d5d0a084705d51c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 21 2007, pradeep singh wrote:
> Hi
> On 6/21/07, Jens Axboe <jens.axboe@oracle.com> wrote:
> >On Thu, Jun 21 2007, pradeep singh wrote:
> >> Hi,
> >>
> >> Chelsio's in kernel 10G driver does not checks the return value from
> >> t1_get_board_info() in cxgb2.c.
> >> t1_get_board_info may return a NULL and we still go on to dereference
> >> it in the for loop without checking for the NULL.
> >>
> >> This patch fixes this.
> >
> >Patch looks odd - bi is dereferenced a number of times after that loop
> >anyway, so I don't see your patch fixing much.
> Thanks for pointing that out Jens.
> Sorry, i pushed it in a haste :(.
> Will check again and resubmit it.

You're welcome. The first thing to do is analyze whether a NULL return
from t1_get_board_info() makes any sense. From a quick look, driver_data
should be the index into the t1 pci table. So if t1_get_board_info()
returns NULL, it must be some core bug. So I'd say either don't handle
it, or mark it with BUG_ON(), or do the !bi check and CH_ERR() a warning
and goto out_disable_pdev.

-- 
Jens Axboe

