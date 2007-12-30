From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24-rc6-mm1
Date: Sun, 30 Dec 2007 12:30:21 +1100
Message-ID: <20071230013021.GA13603@gondor.apana.org.au>
References: <20071222233056.d652743e.akpm@linux-foundation.org> <64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com> <64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com> <20071228150746.42b3bbc0.akpm@linux-foundation.org> <64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753965AbXL3BbT@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 29, 2007 at 05:51:13PM +0100, Torsten Kaiser wrote:
>
> > > The cause, why I am resending this: I just got a crash with
> > > 2.6.24-rc6-mm1, again looking network related:
> > >
> > > [93436.933356] WARNING: at include/net/dst.h:165 dst_release()
> > > [93436.936685] Pid: 8079, comm: konqueror Not tainted 2.6.24-rc6-mm1 #11
> > > [93436.939292]
> > > [93436.939293] Call Trace:
> > > [93436.939304]  [<ffffffff80531d2d>] skb_release_all+0xdd/0x110
> > > [93436.939307]  [<ffffffff80531311>] __kfree_skb+0x11/0xa0
> > > [93436.939309]  [<ffffffff805313b7>] kfree_skb+0x17/0x30
> > > [93436.939312]  [<ffffffff805a0b48>] unix_release_sock+0x128/0x250
> > > [93436.939315]  [<ffffffff805a0c91>] unix_release+0x21/0x30
> > > [93436.939318]  [<ffffffff8052b144>] sock_release+0x24/0x90
> > > [93436.939320]  [<ffffffff8052b656>] sock_close+0x26/0x50
> > > [93436.939324]  [<ffffffff8029f921>] __fput+0xc1/0x230
> > > [93436.939327]  [<ffffffff8029fe46>] fput+0x16/0x20
> > > [93436.939329]  [<ffffffff8029c576>] filp_close+0x56/0x90
> > > [93436.939331]  [<ffffffff8029de46>] sys_close+0xa6/0x110
> > > [93436.939335]  [<ffffffff8020b57b>] system_call_after_swapgs+0x7b/0x80
> 
> >From code inspection I would blame the patch "[SKBUFF]: Free old skb
> properly in skb_morph" from Herbert Xu. (CC added)

I doubt it.  skb_morph is only used on IP fragments so I don't see how
you could attribute an error from a Unix domain socket to this patch.

In any case, Unix socket packets should not have a dst at all so the
very fact that you're in that path means that you have some sort of
memory corruption.

Is this the very first OOPS/warning that you see? If not you should
ignore all but the very first one as that may have left your system
in an inconsistent state which may render all subsequent OOPSes and
warnings useless.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
