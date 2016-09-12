From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit
	more
Date: Mon, 12 Sep 2016 10:53:23 -0700
Message-ID: <20160912175321.GA15135@ast-mbp.thefacebook.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<20160908101147.1b351432@redhat.com>
	<20160909032202.GA62966@ast-mbp.thefacebook.com>
	<20160909073652.351d76d7@redhat.com>
	<20160909063048.GA67375@ast-mbp.thefacebook.com>
	<20160912105655.0cb5607e@redhat.com>
Reply-To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160912105655.0cb5607e-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2016 at 10:56:55AM +0200, Jesper Dangaard Brouer wrote:
> On Thu, 8 Sep 2016 23:30:50 -0700
> Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> > On Fri, Sep 09, 2016 at 07:36:52AM +0200, Jesper Dangaard Brouer wrote:
> > > > >  Lets do bundling/bulking from the start!    
> > > > 
> > > > mlx4 already does bulking and this proposed mlx5 set of patches
> > > > does bulking as well.
> > > > See nothing wrong about it. RX side processes the packets and
> > > > when it's done it tells TX to xmit whatever it collected.  
> > > 
> > > This is doing "hidden" bulking and not really taking advantage of using
> > > the icache more effeciently.  
> > > 
> > > Let me explain the problem I see, little more clear then, so you
> > > hopefully see where I'm going.
> > > 
> > > Imagine you have packets intermixed towards the stack and XDP_TX. 
> > > Every time you call the stack code, then you flush your icache.  When
> > > returning to the driver code, you will have to reload all the icache
> > > associated with the XDP_TX, this is a costly operation.  
> > 
> > correct. And why is that a problem?
> 
> It is good that you can see and acknowledge the I-cache problem.
> 
> XDP is all about performance.  What I hear is, that you are arguing
> against a model that will yield better performance, that does not make
> sense to me.  Let me explain this again, in another way.

I'm arguing against your proposal that I think will be more complex and
lower performance than what Saeed and the team already implemented.
Therefore I don't think it's fair to block the patch and ask them to
reimplement it just to test an idea that may or may not improve performance.

Getting maximum performance is tricky. Good is better than perfect.
It's important to argue about user space visible bits upfront, but
on the kernel performance side we should build/test incrementally.
This particular patch 11/11 is simple, easy to review and provides
good performance. What's not to like?
