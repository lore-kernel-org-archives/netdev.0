From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Fri, 27 Mar 2009 12:39:55 +0100
Message-ID: <OFB3E8CC54.5F056769-ONC1257586.003FF190-C1257586.00401420@transmode.se>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>	
	<2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com>
	<OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se>
	<2a27d3730903270339l44ccb55fo9079402104afc458@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, pku.leo@gmail.com, netdev@vger.kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <2a27d3730903270339l44ccb55fo9079402104afc458@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

pku.leo@gmail.com wrote on 27/03/2009 11:39:07:
> On Fri, Mar 27, 2009 at 6:23 PM, Joakim Tjernlund
> >> > -               /* We freed a buffer, so now we can restart
> > transmission */
> >> > -               if (netif_queue_stopped(dev))
> >> > -                       netif_wake_queue(dev);
> >> > +               dev_kfree_skb(ugeth->tx_skbuff[txQ][tx_ind]);
> >> > +               ugeth->tx_skbuff[txQ][tx_ind] = NULL;
> >> > +               out_be32(bd2buf(bd), 0); /* Mark it free */
> >>
> >> Now I see why you depend on the buffer to judge if the BD ring is
> >> full.  If you want to do this, make sure it's well documented in 
code,
> >> or others will be confused.  And as Anton already commented, in/out
> >> access is slow.  I think the original way can be fixed if you think
> >> it's broken, and will have better performance.
> >
> > The code could use a better comment, but I really think this method
> > is superior and more robust. The problem is that in/out functions is
> > much slower than it has to be for QE IO memory.
> >
> > The original way is broken and I tired to fix it but it always broke
> > as soon one applied some load.
> 
> The only difference I see between your method and the original code is
> that you update the cleanup progress on every BD.  The original code
> updates progress only after all sent BDs are processed.  You can try
> move ugeth->confBd[txQ] = bd; into the loop then it will be the same
> as your proposed code.

Already tried that+lots of other combinatios. Doesn't work
