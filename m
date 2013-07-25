From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Patch net-next 4/7] sunrpc: use generic union inet_addr
Date: Thu, 25 Jul 2013 20:34:43 +0800
Message-ID: <1374755683.29923.7.camel@cr0>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <1374476713-8838-5-git-send-email-amwang@redhat.com>
	 <20130723164051.GE12569@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130723164051.GE12569-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-07-23 at 12:40 -0400, J. Bruce Fields wrote:
> On Mon, Jul 22, 2013 at 03:05:10PM +0800, Cong Wang wrote: 
> >  static inline unsigned short rpc_get_port(const struct sockaddr *sap)
> >  {
> > -	switch (sap->sa_family) {
> > -	case AF_INET:
> > -		return ntohs(((struct sockaddr_in *)sap)->sin_port);
> > -	case AF_INET6:
> > -		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
> > -	}
> > -	return 0;
> > +	return inet_addr_get_port((const union inet_addr *)sap);
> >  }
> 
> Is there any reason to keep the rpc_get_port wrapper at all after this?
> Or if its still useful to have the convenience of not having to do the
> cast, maybe the wrapper should move to common code to?  (Is there some
> reason only the rpc code needs this?)
> 

Yeah, the only reason why I keep it is that I don't want to touch all
the callers of rpc_get_port(). I agree that we can make it a generic
function.

Thanks.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
