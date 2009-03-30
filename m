From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH 1/2] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Mon, 30 Mar 2009 09:48:01 +0200
Message-ID: <OF8F2A374C.8C3B68EA-ONC1257589.002A7868-C1257589.002AD913@transmode.se>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>	 <2a27d3730903270350m52fcb837ge78c0b87cc3887d5@mail.gmail.com>
	 <OF073D5C49.F0D791DE-ONC1257586.0040163D-C1257586.00413F47@transmode.se> <2a27d3730903300036x1dc265a3o76ea36ca6a16fb5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: avorontsov@ru.mvista.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, pku.leo@gmail.com
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:38254 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637AbZC3HsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 03:48:06 -0400
In-Reply-To: <2a27d3730903300036x1dc265a3o76ea36ca6a16fb5b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pku.leo@gmail.com wrote on 30/03/2009 09:36:21:
> 
> On Fri, Mar 27, 2009 at 7:52 PM, Joakim Tjernlund
> <Joakim.Tjernlund@transmode.se> wrote:
> > pku.leo@gmail.com wrote on 27/03/2009 11:50:09:
> >>
> >> On Thu, Mar 26, 2009 at 8:54 PM, Joakim Tjernlund
> >> <Joakim.Tjernlund@transmode.se> wrote:
> >> > Also set NAPI weight to 64 as this is a common value.
> >> > This will make the system alot more responsive while
> >> > ping flooding the ucc_geth ethernet interaface.
> >> >
> >> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> >> > ---
> >> >        /* Errors and other events */
> >> >        if (ucce & UCCE_OTHER) {
> >> >                if (ucce & UCC_GETH_UCCE_BSY)
> >> > @@ -3733,7 +3725,7 @@ static int ucc_geth_probe(struct of_device*
> > ofdev, const struct of_device_id *ma
> >> >        dev->netdev_ops = &ucc_geth_netdev_ops;
> >> >        dev->watchdog_timeo = TX_TIMEOUT;
> >> >        INIT_WORK(&ugeth->timeout_work, ucc_geth_timeout_work);
> >> > -       netif_napi_add(dev, &ugeth->napi, ucc_geth_poll,
> > UCC_GETH_DEV_WEIGHT);
> >> > +       netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, 64);
> >>
> >> It doesn't make sense to have larger napi budget than the size of RX
> >> BD ring.  You can't have more BDs than RX_BD_RING_LEN in backlog for
> >> napi_poll to process.  Increase the RX_BD_RING_LEN if you want to
> >> increase UCC_GETH_DEV_WEIGHT.  However please also provide the
> >> performance comparison for this kind of change.  Thanks
> >
> > Bring it up with David Miller. After my initial attempt to just 
increase
> > weight somewhat, he requested that I hardcoded it to 64. Just read the
> > whole thread.
> > If I don't increase weight somewhat, ping -f -l 3 almost halts the 
board.
> > Logging
> > in takes forever. These are my "performance numbers".
> 
> Faster response time is surely good.  But it might also mean CPU is
> not fully loaded.  IMHO, throughput is a more important factor for
> network devices.  When you try to optimize the driver, please also
> consider the throughput change.  Thanks.

This particular change isn't about performance, it is about not
"bricking" the board during heavy traffic. Next step is to optimize
the driver.

 Jocke
