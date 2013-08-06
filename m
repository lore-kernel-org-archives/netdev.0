From: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Patch net-next v2 5/8] sunrpc: use generic union inet_addr
Date: Tue, 6 Aug 2013 06:28:01 -0400
Message-ID: <20130806062801.67714276@tlielax.poochiereds.net>
References: <1375427674-21735-1-git-send-email-amwang@redhat.com>
	<1375427674-21735-6-git-send-email-amwang@redhat.com>
	<20130802093625.2c70a330@tlielax.poochiereds.net>
	<1375672445.32485.8.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375672445.32485.8.camel@cr0>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 05 Aug 2013 11:14:05 +0800
Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On Fri, 2013-08-02 at 09:36 -0400, Jeff Layton wrote:
> > On Fri,  2 Aug 2013 15:14:31 +0800
> > Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > 
> > > From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > 
> > > sunrpc defines some helper functions for sockaddr, actually they
> > > can re-use the generic functions for union inet_addr too.
> > 
> > Only some of these patches in this series have made it to lists to
> > which I'm subscribed, so I may be missing some context here...
> > 
> > I'm not sure I really understand the value of "union inet_addr". Why
> > not just use the conventional method of passing around "struct sockaddr"
> > pointers, and then casting them to struct sockaddr_in/sockaddr_in6
> > depending on what the sa_family is set to?
> 
> Yes.
> 
> > 
> > With that you wouldn't need to leave the (now pointless) rpc_* wrappers
> > in place and could just call your new helpers directly.
> > 
> 
> J. Bruce asked the same question, see:
> http://marc.info/?l=linux-nfs&m=137475685903460&w=2
> 

Not exactly...

He asked why you were keeping the wrappers and you replied that it was
because you didn't want to change all of the callers of rpc_get_port.
That's a fair enough answer to his question.

My question is a bit more fundamental: Why are you using this new union
in your patches instead of simply passing around "struct sockaddr"
pointers? If you did that, then you could simply replace all of the
rpc_* wrappers with your generic ones, since you wouldn't need to do
the cast to this (seemingly unnecessary) union.

FWIW, I too am happy to see these routines moved to common code. I just
wonder whether it might make more sense to use the existing convention
instead of this new union.

-- 
Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
