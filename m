From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ucc_geth: Move freeing of TX packets to NAPI
 context.
Date: Fri, 27 Mar 2009 14:55:02 -0700 (PDT)
Message-ID: <20090327.145502.214872726.davem@davemloft.net>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
	<2a27d3730903270350m52fcb837ge78c0b87cc3887d5@mail.gmail.com>
	<OF073D5C49.F0D791DE-ONC1257586.0040163D-C1257586.00413F47@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, avorontsov@ru.mvista.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, pku.leo@gmail.com
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43544
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758339AbZC0VzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 17:55:14 -0400
In-Reply-To: <OF073D5C49.F0D791DE-ONC1257586.0040163D-C1257586.00413F47@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Fri, 27 Mar 2009 12:52:41 +0100

> pku.leo@gmail.com wrote on 27/03/2009 11:50:09:
> > It doesn't make sense to have larger napi budget than the size of RX
> > BD ring.  You can't have more BDs than RX_BD_RING_LEN in backlog for
> > napi_poll to process.  Increase the RX_BD_RING_LEN if you want to
> > increase UCC_GETH_DEV_WEIGHT.  However please also provide the
> > performance comparison for this kind of change.  Thanks
> 
> Bring it up with David Miller.

Right I told him to make this very change.

Pretty soon the driver's won't be able to select this value
and it will default to 64 everwhere anyways.

"performance comparison"?  He can't do that unless he tests
performance with two active NAPI devices on the same exact
cpu as the weight value is for fairness between devices.

So you don't tweak "weight" to make one device perform better,
you tweak it to eliminate unfairness between multiple devices.
And the only way to achieve that is to use similar values
across all devices, perhaps link-speed rated which we can't
do just yet, and that's why I told him to use 64 just like
every other driver basically does.
