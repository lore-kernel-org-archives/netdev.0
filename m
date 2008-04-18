From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] Removal of debug code containing deprecated calls to cli()/sti()
Date: Fri, 18 Apr 2008 13:07:29 -0600
Message-ID: <20080418190729.GE20637@parisc-linux.org>
References: <200804181455.m3IEtje2032231@cmf.nrl.navy.mil> <1208543806-9127-1-git-send-email-mark.asselstine@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, chas@cmf.nrl.navy.mil,
	netdev@vger.kernel.org, asselsm@gmail.com
To: Mark Asselstine <mark.asselstine@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:38083 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760875AbYDRTHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 15:07:31 -0400
Content-Disposition: inline
In-Reply-To: <1208543806-9127-1-git-send-email-mark.asselstine@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2008 at 02:36:46PM -0400, Mark Asselstine wrote:
> -   ns_grab_res_lock(card, flags);
> +   spin_lock_irqsave(&(card)->res_lock,(flags));

We generally prefer the form:

	spin_lock_irqsave(&card->res_lock, flags);

The brackets aren't needed and since they aren't used elsewhere in the
kernel, breaking the pattern makes it look like these are somehow
different (which they aren't).

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
