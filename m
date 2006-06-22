From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC 2/7] NetLabel: core network changes
Date: Thu, 22 Jun 2006 09:20:33 -0400
Message-ID: <200606220920.34136.paul.moore@hp.com>
References: <20060621194234.979661000@flek.zko.hp.com>
	<20060621200030.880930000@flek.zko.hp.com>
	<20060622.020748.85685000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, sds@epoch.ncsc.mil, redhat-lspp@redhat.com,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, sgrubb@redhat.com
Return-path: <redhat-lspp-bounces@redhat.com>
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060622.020748.85685000.davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/redhat-lspp>
List-Post: <mailto:redhat-lspp@redhat.com>
List-Help: <mailto:redhat-lspp-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=subscribe>
Sender: redhat-lspp-bounces@redhat.com
Errors-To: redhat-lspp-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Thursday 22 June 2006 5:07 am, David Miller wrote:
> From: paul.moore@hp.com
> Date: Wed, 21 Jun 2006 15:42:37 -0400
>
> > Index: linux-2.6.17.i686-quilt/net/ipv4/Makefile
> > ===================================================================
> > --- linux-2.6.17.i686-quilt.orig/net/ipv4/Makefile
> > +++ linux-2.6.17.i686-quilt/net/ipv4/Makefile
> > @@ -42,6 +42,9 @@ obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybl
> >  obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
> >  obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
> >  obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
> > +ifeq ($(CONFIG_NETLABEL_CIPSOV4),y)
> > +obj-y += cipso_ipv4.o
> > +endif
>
> Why not "obj-$CONFIG_NETLABEL_CIPSOV4 += cipso_ipv4.o"?
>
> The whole idea behind the obj-$CONFIG_OPTION technique is
> to avoid conditionals all over the makefile.

Because it's not supported as a module and I thought I saw some similar 
examples in other Makefiles.  No matter, I'll make the change.

> > Index: linux-2.6.17.i686-quilt/net/ipv4/af_inet.c
> > ===================================================================
> > --- linux-2.6.17.i686-quilt.orig/net/ipv4/af_inet.c
> > +++ linux-2.6.17.i686-quilt/net/ipv4/af_inet.c
> > @@ -114,6 +114,7 @@
> >  #ifdef CONFIG_IP_MROUTE
> >  #include <linux/mroute.h>
> >  #endif
> > +#include <net/netlabel.h>
> >
> >  DEFINE_SNMP_STAT(struct linux_mib, net_statistics) __read_mostly;
> >
> > @@ -616,6 +617,8 @@ int inet_accept(struct socket *sock, str
> >
> >  	sock_graft(sk2, newsock);
> >
> > +	netlbl_socket_inet_accept(sock, newsock);
> > +
> >  	newsock->state = SS_CONNECTED;
> >  	err = 0;
> >  	release_sock(sk2);
>
> Neither the netlabel.h header not the implementation of
> the netlbl_socket_inet_accept() function exist at this
> point in your patch set.
>
> At each patch point, the tree must build and function
> properly.
>
> This means you have to split up and order your changes
> correctly, gradually building up the infrastructure and
> then finally plugging it in and making use of it.
>
> Nobody can test your work in an incremental fashion, and
> thus it's not possible to determine if a bug or behavior
> gets introduced at patch 2, 3 or 4, for example.

I intended the entire patch set to be digested as a whole, the only reason I 
split it up into several different patches was to get around size limitations 
in the mailing list.  I'll go ahead and rearrange things so they build 
incrementally.

Thanks for your patience.

-- 
paul moore
linux security @ hp
