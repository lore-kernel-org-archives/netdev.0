From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFT] vxlan: listen on multiple ports
Date: Wed, 15 May 2013 23:20:58 -0700
Message-ID: <20130515232058.46ef3135@samsung-9>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>
	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
	<20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
	<OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com>
	<20130515104825.5cbeaee3@nehalam.linuxnetplumber.net>
	<OF1177AC77.13B8F09E-ON85257B6C.0064777A-85257B6C.0066B974@us.ibm.com>
	<20130515143702.38730c3d@nehalam.linuxnetplumber.net>
	<1368672673.12751.19.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:55612 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252Ab3EPGVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 02:21:07 -0400
Received: by mail-da0-f47.google.com with SMTP id k13so1451860dae.34
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 23:21:06 -0700 (PDT)
In-Reply-To: <1368672673.12751.19.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 May 2013 10:51:13 +0800
Cong Wang <amwang@redhat.com> wrote:

> On Wed, 2013-05-15 at 14:37 -0700, Stephen Hemminger wrote:
> > The earlier change to introduce per-vxlan UDP port configuration did only
> > half the necessary work. It added per vxlan destination for sending, but
> > overlooked the handling of multiple ports for incoming, which means it
> > is broken.
> > 
> > This patch changes the listening port management to handle multiple
> > incoming UDP ports. The earlier per-namespace structure is now a hash
> > list per namespace.
> > 
> > It is also now possible to define the same virtual network id
> > but with different UDP port values.
> > 
> 
> Besides fixing the default port issue, what other benefits does it have?
> This seems overkill.
> 
> It looks like you make one socket per port, after my IPv6 patches, we
> would have two sockets per port...
> 
> 

The destination port option is broken now. It only sets the port
for outgoing packets, it does not change port used for incoming packets.
This change is to address that. Sorry, it shouldn't be a big
impact for IPv6.
