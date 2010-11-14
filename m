From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH 2/2] ucc_geth: Fix deadlock
Date: Sun, 14 Nov 2010 15:43:37 +0100
Message-ID: <OF95BC4C89.14730D6A-ONC12577DB.005073FE-C12577DB.0050E5CE@transmode.se>
References: <1289570109-8160-1-git-send-email-Joakim.Tjernlund@transmode.se> <1289570109-8160-2-git-send-email-Joakim.Tjernlund@transmode.se> <20101112140947.GB28223@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Anton Vorontsov <cbouatmailru@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:44330 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751775Ab0KNOnm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Nov 2010 09:43:42 -0500
In-Reply-To: <20101112140947.GB28223@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov <cbouatmailru@gmail.com> wrote on 2010/11/12 15:09:47:
>
> On Fri, Nov 12, 2010 at 02:55:09PM +0100, Joakim Tjernlund wrote:
> > This script:
> >  while [ 1==1 ] ; do ifconfig eth0 up; usleep 1950000 ;ifconfig eth0 down; dmesg -c ;done
> > causes in just a second or two:
> > INFO: task ifconfig:572 blocked for more than 120 seconds.
> [...]
> > The reason appears to be ucc_geth_stop meets adjust_link as the
> > PHY reports PHY changes. I belive adjust_link hangs somewhere,
> > holding the PHY lock, because ucc_geth_stop disabled the
> > controller HW.
> > Fix is to stop the PHY before disabling the controller.
> >
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
>
> It's unclear where exactly adjust_link() hangs, but the patch
> looks as the right thing overall.

Yes, I too cannot find where it is hanging, just that it is hanging somewhere.
I am starting to think it is hanging somewhere else. Anyhow, the hang
goes away 100% when this patch is applied.

 Jocke

