From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Wed, 15 May 2013 09:53:22 -0700
Message-ID: <20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>
	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35358 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932901Ab3EOQx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 12:53:26 -0400
Received: by mail-pd0-f177.google.com with SMTP id g10so1520008pdj.22
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 09:53:26 -0700 (PDT)
In-Reply-To: <OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 May 2013 07:32:28 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> netdev-owner@vger.kernel.org wrote on 05/15/2013 07:11:10 AM:
> 
> > From: Cong Wang <amwang@redhat.com>
> 
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > 
> > ---
> > diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
> > index 2d93ee2..a0c90b3 100644
> > --- a/ip/iplink_vxlan.c
> > +++ b/ip/iplink_vxlan.c
> > @@ -53,7 +53,7 @@ static int vxlan_parse_opt(struct link_util *lu, 
> > int argc, char **argv,
> >     __u8 noage = 0;
> >     __u32 age = 0;
> >     __u32 maxaddr = 0;
> > -   __u16 dstport = 4789;
> > +   __u16 dstport = 8472;
> 
> I think this should be "0"; then it will use the kernel port,
> whatever it is.
> 
> > @@ -188,8 +188,7 @@ static int vxlan_parse_opt(struct link_util *lu,
> > int argc, char **argv,
> >     if (range.low || range.high)
> >        addattr_l(n, 1024, IFLA_VXLAN_PORT_RANGE,
> >             &range, sizeof(range));
> > -   if (dstport)
> > -      addattr16(n, 1024, IFLA_VXLAN_PORT, htons(dstport));
> > +   addattr16(n, 1024, IFLA_VXLAN_PORT, htons(dstport));
> 
>         ...and these lines should be left alone. If not specified,
> it won't pass an alternate port and will use the kernel default.
> 
>                                                 +-DLS
> 
> 

No. I want all users to get the IANA assigned port unless they specifically
override it. For compatibility kernel can't change to the IANA value
but user space needs to nudge users in the correct direction.
