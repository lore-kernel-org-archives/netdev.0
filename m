From: Roger Pau =?iso-8859-1?Q?Monn=E9?= <roger.pau@citrix.com>
Subject: Re: [Xen-devel] [PATCH v2 net-next 2/7] xen-netback: retire guest rx
 side prefix GSO feature
Date: Wed, 5 Oct 2016 17:30:26 +0200
Message-ID: <20161005153026.ihxdtvu3hgpjql4o@mac>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
 <1475573358-32414-3-git-send-email-paul.durrant@citrix.com>
 <20161004125205.GE30836@localhost.localdomain>
 <6af51a0a84cf41d5a31168b3e8626fcd@AMSPEX02CL03.citrite.net>
 <20161004142404.GC18821@char.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Paul Durrant <Paul.Durrant@citrix.com>, <bouyer@NetBSD.org>,
        "annie.li@oracle.com" <annie.li@oracle.com>,
        "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        Wei Liu <wei.liu2@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34398 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753161AbcJEPbE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 11:31:04 -0400
Content-Disposition: inline
In-Reply-To: <20161004142404.GC18821@char.us.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 04, 2016 at 10:24:04AM -0400, Konrad Rzeszutek Wilk wrote:
> On Tue, Oct 04, 2016 at 01:35:41PM +0000, Paul Durrant wrote:
> > > -----Original Message-----
> > > From: Konrad Rzeszutek Wilk [mailto:konrad.wilk@oracle.com]
> > > Sent: 04 October 2016 13:52
> > > To: Paul Durrant <Paul.Durrant@citrix.com>; annie.li@oracle.com;
> > > joao.m.martins@oracle.com
> > > Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org; Wei Liu
> > > <wei.liu2@citrix.com>
> > > Subject: Re: [Xen-devel] [PATCH v2 net-next 2/7] xen-netback: retire guest
> > > rx side prefix GSO feature
> > > 
> > > On Tue, Oct 04, 2016 at 10:29:13AM +0100, Paul Durrant wrote:
> > > > As far as I am aware only very old Windows network frontends make use
> > > > of this style of passing GSO packets from backend to frontend. These
> > > > frontends can easily be replaced by the freely available Xen Project
> > > > Windows PV network frontend, which uses the 'default' mechanism for
> > > > passing GSO packets, which is also used by all Linux frontends.
> > > 
> > > It is not that simple. Some companies have extra juice in their Windows
> > > frontends so can't easily swap over to the Xen Project one.
> > 
> > Ok, then those frontends will continue to work, but they won't get GSO packets any more. Prefix GSO has never been specified in the canonical netif header and so has been in a limbo state forever so such frontends have always been on borrowed time and only just happened to work against a linux backend. If someone wants to actually specify prefix GSO properly then it could be added back in, but it should not be necessary now that the RX side req<->rsp identity relation is documented (http://xenbits.xen.org/gitweb/?p=xen.git;a=blob;f=xen/include/public/io/netif.h;hb=HEAD#l729).
> > 
> > > 
> > > Either way CC-ing Annie
> > > 
> > > Also would it make sense to CC the FreeBSD and NetBSD maintainers of their
> > > PV drivers just to make sure? (Or has that been confirmed)
> > > 
> > 
> > I could do that, but I'd hope that they would be subscribed to xen-devel and will chime in if there's likely to be a problem.
> 
> Usually one CCs those folks. I think you are asking me to do
> the legwork and find them and CC them here?
> 
> CC-ing Roger and  Manuel Bouyer.

Thanks. FreeBSD is using the same method as current Linux in order to both 
send and receive GSO packets. That is using an extra slot in the ring, 
filled with a netif_extra_info of type XEN_NETIF_EXTRA_TYPE_GSO. Full code 
can be found here [0], but AFAICT FreeBSD is not using this prefix stuff.

Also, IIRC NetBSD doesn't have a Xen GSO implementation [1], but I would let 
Manuel answer that one.

Roger.

[0] http://fxr.watson.org/fxr/source/dev/xen/netfront/netfront.c
[1] https://github.com/jsonn/src/blob/trunk/sys/arch/xen/xen/if_xennet_xenbus.c
