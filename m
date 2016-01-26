From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] fddi: Fixup potential uninitialized bars
Date: Tue, 26 Jan 2016 08:55:41 +0000 (GMT)
Message-ID: <alpine.LFD.2.20.1601260759180.7055@eddie.linux-mips.org>
References: <1453793251-101247-1-git-send-email-hare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.com>,
	Hannes Reinecke <hare@suse.com>
To: Hannes Reinecke <hare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:55576 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933887AbcAZJDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 04:03:45 -0500
Received: (from localhost user: 'macro', uid#1010) by eddie.linux-mips.org
        with ESMTP id S27010456AbcAZIzl7eQ71 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 09:55:41 +0100
In-Reply-To: <1453793251-101247-1-git-send-email-hare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jan 2016, Hannes Reinecke wrote:

> dfx_get_bars() allocates the various bars, depending on the
> bus type. But as the function itself returns void and there
> is no default selection there is a risk of the function
> returning without allocating any bars.
> This patch moves the entries around so that PCI is assumed
> to the the default bus, and adds a WARN_ON check if that
> should no be the case.
> And I've made some minor code reshuffles to keep checkpatch
> happy.
> 
> Signed-off-by: Hannes Reinecke <hare@suse.com>
> ---
>  drivers/net/fddi/defxx.c | 29 ++++++++++++++++-------------
>  1 file changed, 16 insertions(+), 13 deletions(-)

 NAK, this has been fixed already with a much simpler change, commit 
62f2aaabcf41 ("defxx: fix build warning").  Exactly one of `dfx_bus_pci', 
`dfx_bus_eisa' or `dfx_bus_tc' will always be true or `dfx_register' will 
not have been called in the first place, so it's not even worth a BUG_ON 
IMHO.

 Thanks for looking into this problem though, always welcome!

  Maciej
