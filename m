From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iptuntap: allow creation of multi-queue tun/tap device
Date: Mon, 10 Jun 2013 10:16:17 -0700
Message-ID: <20130610101617.6859448e@nehalam.linuxnetplumber.net>
References: <1369348589-38730-1-git-send-email-sriram.narasimhan@hp.com>
	<20130609111123.GA16406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sriram Narasimhan <sriram.narasimhan@hp.com>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:56298 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573Ab3FJRQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 13:16:21 -0400
Received: by mail-pd0-f175.google.com with SMTP id 4so7623872pdd.34
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 10:16:21 -0700 (PDT)
In-Reply-To: <20130609111123.GA16406@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 9 Jun 2013 14:11:23 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Thu, May 23, 2013 at 03:36:29PM -0700, Sriram Narasimhan wrote:
> > This patch adds multi_queue option to ip tuntap.
> > This allows IFF_MULTI_QUEUE flag to be specified during
> > tun/tap device creation enabling multi-queue support in tun/tap
> > device.
> > 
> > Example: ip tuntap add dev tap0 mode tap multi_queue
> > 
> > Signed-off-by: Sriram Narasimhan <sriram.narasimhan@hp.com>
> 
> Looks useful.
> 
> Stephen, what do you think?
> Could you pick this up please?
> 
> > ---
> >  ip/iptuntap.c |    4 +++-
> >  1 files changed, 3 insertions(+), 1 deletions(-)
> > 
> > diff --git a/ip/iptuntap.c b/ip/iptuntap.c
> > index 3d9ad7d..2391af2 100644
> > --- a/ip/iptuntap.c
> > +++ b/ip/iptuntap.c
> > @@ -38,7 +38,7 @@ static void usage(void)
> >  {
> >  	fprintf(stderr, "Usage: ip tuntap { add | del } [ dev PHYS_DEV ] \n");
> >  	fprintf(stderr, "          [ mode { tun | tap } ] [ user USER ] [ group GROUP ]\n");
> > -	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ]\n");
> > +	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ] [ multi_queue ]\n");
> >  	fprintf(stderr, "\n");
> >  	fprintf(stderr, "Where: USER  := { STRING | NUMBER }\n");
> >  	fprintf(stderr, "       GROUP := { STRING | NUMBER }\n");
> > @@ -168,6 +168,8 @@ static int parse_args(int argc, char **argv, struct ifreq *ifr, uid_t *uid, gid_
> >  			ifr->ifr_flags |= IFF_ONE_QUEUE;
> >  		} else if (matches(*argv, "vnet_hdr") == 0) {
> >  			ifr->ifr_flags |= IFF_VNET_HDR;
> > +		} else if (matches(*argv, "multi_queue") == 0) {
> > +			ifr->ifr_flags |= IFF_MULTI_QUEUE;
> >  		} else if (matches(*argv, "dev") == 0) {
> >  			NEXT_ARG();
> >  			strncpy(ifr->ifr_name, *argv, IFNAMSIZ-1);
> > -- 
> > 1.7.1
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

Already applied to iproute2 for 3.10
