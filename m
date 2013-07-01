From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC Patch net-next 4/5] sunrpc: use generic union inet_addr
Date: Mon, 01 Jul 2013 15:11:57 +0800
Message-ID: <1372662717.2974.23.camel@cr0>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-5-git-send-email-amwang@redhat.com>
	 <1372347413.2436.6.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372347413.2436.6.camel-/LGg1Z1CJKQ+9kgCwbf1HqK4ta4zdZpAajtMo4Cw6ucAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-27 at 16:36 +0100, Ben Hutchings wrote:
> On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote:
> [...]
> > -/**
> > - * rpc_cmp_addr - compare the address portion of two sockaddrs.
> > - * @sap1: first sockaddr
> > - * @sap2: second sockaddr
> > - *
> > - * Just compares the family and address portion. Ignores port, but
> > - * compares the scope if it's a link-local address.
> 
> You're removing the scope comparison.

Actually I added the following code in patch 5/5:

+               if (!ipv6_addr_equal(&a->sin6.sin6_addr,
&b->sin6.sin6_addr))
+                       return false;
+               else if
(__ipv6_addr_needs_scope_id(__ipv6_addr_type(&a->sin6.sin6_addr)))
+                       return a->sin6.sin6_scope_id ==
b->sin6.sin6_scope_id;


but I should move it to this patch, otherwise it is hard for review.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
