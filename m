From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Tue, 9 Aug 2016 11:08:30 -0700
Message-ID: <20160809180830.GM22974@cork>
References: <20160808211530.GH22974@cork>
 <20160808212112.GI22974@cork>
 <20160808214812.GJ22974@cork>
 <57A93D81.4030808@huawei.com>
 <20160809030956.GL22974@cork>
 <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com>
 <57A9DA8D.3010407@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: zhuyj <zyjzyj2000@gmail.com>, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33374 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbcHISJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 14:09:35 -0400
Received: by mail-pa0-f49.google.com with SMTP id ti13so7525806pac.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 11:08:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57A9DA8D.3010407@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 09, 2016 at 09:28:45PM +0800, Ding Tianhong wrote:
> 
> This patch is a simple solution for this problem, but I don't think it is the right solution, the bond is a virtual device base on L2,
> if the slave has no mac address, it will break the design principle, so we need to think more about it.

The important point is: it worked.  It solved a problem that at least
three people cared enough about to send a bug report.

Now it doesn't work anymore.  That is a regression.

Whether or not L2 has always been a design principle for bonding can be
argued as well.  But in the face of a regression, I suggest we fix the
regression.

> I think if the bonding dev has to support L3 virtual device, we need to add new bond features to distinguish the dev and make the
> bond xmit and transfer without the mac address.

Simply not checking errors when setting the mac address solves the
problem for me.  No new features needed.

If you want to retain error handling, you can make those checks
conditional on the mode.  In balance-rr or broadcast mode, ignore the
error.  I don't need and haven't tested broadcast mode, but it doesn't
seem to depend on any L2 attributes either.

Jörn
