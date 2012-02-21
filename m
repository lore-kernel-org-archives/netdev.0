From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/2] vhost: allow multiple workers threads
Date: Tue, 21 Feb 2012 05:21:48 +0200
Message-ID: <20120221032147.GB2502@redhat.com>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com>
 <1329519726-25763-2-git-send-email-aliguori@us.ibm.com>
 <20120219144145.GA16620@redhat.com>
 <OFC071CE44.FE2F733D-ON862579AA.0055FCA0-862579AA.0057082B@us.ibm.com>
 <20120220192708.GA18308@redhat.com>
 <4F42A2FB.7000501@us.ibm.com>
 <20120220210005.GA19278@redhat.com>
 <1329786250.13141.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <aliguori@us.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>, netdev@vger.kernel.org,
	Cristian Viana <vianac@br.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478Ab2BUDVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 22:21:49 -0500
Content-Disposition: inline
In-Reply-To: <1329786250.13141.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 20, 2012 at 05:04:10PM -0800, Shirley Ma wrote:
> On Mon, 2012-02-20 at 23:00 +0200, Michael S. Tsirkin wrote:
> > 
> > The point was really to avoid scheduler overhead
> > as with tcp, tx and rx tend to run on the same cpu.
> 
> We have tried different approaches in the past, like splitting vhost
> thread to separate TX, RX threads; create per cpu vhost thread instead
> of creating per VM per virtio_net vhost thread... 
> 
> We think per cpu vhost thread is a better approach based on the data we
> have collected. It will reduce both vhost resource and scheduler
> overhead. It will not depend on host scheduler, has less various. The
> patch is under testing, we hope we can post it soon.
> 
> Thanks
> Shirley

Yes, great, this is definitely interesting. I actually started with
a per-cpu one - it did not perform well but I did not
figure out why, switching to a single thread fixed it
and I did not dig into it.


-- 
MST
