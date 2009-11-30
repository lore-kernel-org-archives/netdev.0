From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: [patch] drop chan->wsem on error path
Date: Mon, 30 Nov 2009 08:44:18 +0100
Message-ID: <20091130074418.GC25334@fi.muni.cz>
References: <20091129160255.GN10640@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:45194 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920AbZK3Hwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 02:52:36 -0500
Content-Disposition: inline
In-Reply-To: <20091129160255.GN10640@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter wrote:
: The other paths all drop chan->wsem.  This was found by a static
: checker (smatch).

	You are right, thanks!

: 
: Signed-off-by: Dan Carpenter <error27@gmail.com>

Acked-by: Jan "Yenya" Kasprzak <kas@fi.muni.cz>

: --- orig/drivers/net/wan/cosa.c	2009-11-29 16:38:42.000000000 +0200
: +++ devel/drivers/net/wan/cosa.c	2009-11-29 16:43:39.000000000 +0200
: @@ -907,6 +907,7 @@ static ssize_t cosa_write(struct file *f
:  			current->state = TASK_RUNNING;
:  			chan->tx_status = 1;
:  			spin_unlock_irqrestore(&cosa->lock, flags);
: +			up(&chan->wsem);
:  			return -ERESTARTSYS;
:  		}
:  	}

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/    Journal: http://www.fi.muni.cz/~kas/blog/ |
Please don't top post and in particular don't attach entire digests to your
mail or we'll all soon be using bittorrent to read the list.     --Alan Cox
