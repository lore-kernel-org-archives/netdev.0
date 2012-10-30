From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Tue, 30 Oct 2012 20:26:40 +0100
Message-ID: <20121030192639.GA31574@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1351589962.17077.36.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1351589962.17077.36.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2012 at 09:39:22AM +0000, David Woodhouse wrote:
> On Mon, 2012-10-22 at 19:14 +0200, Krzysztof Mazur wrote:
> > The pppoatm gets a reference to atmvcc, but does not increment vcc
> > usage count. The vcc uses vcc->sk socket for reference counting,
> > so sock_hold() and sock_put() should be used by pppoatm.
> > 
> > Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
> > Cc: David Woodhouse <dwmw2@infradead.org>
> 
> Acked-By: David Woodhouse <David.Woodhouse@intel.com>

This patch is not needed, because vcc_destroy_socket()
calls pppoatm_push(vcc, NULL) to indicate that vcc is now closed,
before vcc_release() calls sock_put() and it's properly handled
by pppoatm.

I will drop this patch.

> 
> But did you spot what's in the end of the context of the first hunk...?
> 
> > --- a/net/atm/pppoatm.c
> > +++ b/net/atm/pppoatm.c
> > @@ -154,6 +154,7 @@ static void pppoatm_unassign_vcc(struct atm_vcc
> > *atmvcc)
> >         tasklet_kill(&pvcc->wakeup_tasklet);
> >         ppp_unregister_channel(&pvcc->chan);
> >         atmvcc->user_back = NULL;
> > +       sock_put(sk_atm(pvcc->atmvcc));
> >         kfree(pvcc);
> >         /* Gee, I hope we have the big kernel lock here... */
> >         module_put(THIS_MODULE);
> 
> Fairly sure that hope is unfounded these days... :)
> 

Yes, I saw that.

Thanks.

Krzysiek
