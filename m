From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6.26 2/2] Do not allocate unneeded memory for
	dev->priv alignment.
Date: Tue, 8 Apr 2008 09:22:53 +0000
Message-ID: <20080408092253.GA4048@ff.dom.local>
References: <47FA4C50.3080405@openvz.org> <47FA5D62.5040806@gmail.com> <47FB2FF3.90104@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:34982 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbYDHJU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 05:20:26 -0400
Received: by an-out-0708.google.com with SMTP id d31so420609and.103
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2008 02:20:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47FB2FF3.90104@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 08, 2008 at 12:42:27PM +0400, Pavel Emelyanov wrote:
> Jarek Poplawski wrote:
> > Pavel Emelyanov wrote, On 04/07/2008 06:31 PM:
> > ...
> > 
> >> ---
> >>  net/core/dev.c |    3 ++-
> >>  1 files changed, 2 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/net/core/dev.c b/net/core/dev.c
> >> index 7aa0112..80e103a 100644
> >> --- a/net/core/dev.c
> >> +++ b/net/core/dev.c
> >> @@ -4000,7 +4000,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
> >>  	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
> >>  		     (sizeof(struct net_device_subqueue) * (queue_count - 1))) &
> >>  		     ~NETDEV_ALIGN_CONST;
> >> -	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
> >> +	if (sizeof_priv)
> >> +		alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
> >>  
> >>  	p = kzalloc(alloc_size, GFP_KERNEL);
> >>  	if (!p) {
> > 
> > 
> > IMHO this second "+ NETDEV_ALIGN_CONST" is needed here because of "~NETDEV_ALIGN_CONST".
> 
> Hmm, AFAIC, the net_device alignment is done earlier, while this one
> makes sense in case the priv pointer alignment.

Hmm, one NETDEV_ALIGN_CONST is later used just for net_device alignment,
and you could not fit this struct after "~NETDEV_ALIGN_CONST" without
adding anything. So you should probably skip "~NETDEV_ALIGN_CONST" in
this no priv case too?

Jarek P.
