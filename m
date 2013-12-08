From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] virtio_net: multicast address list never sent to host
Date: Sun, 8 Dec 2013 11:43:19 -0800
Message-ID: <20131208114319.31ac0e27@nehalam.linuxnetplumber.net>
References: <20131205152052.064319c9@nehalam.linuxnetplumber.net>
	<20131208123526.GA10037@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alex Williamson <alex.williamson@hp.com>,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:59587 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040Ab3LHTnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 14:43:22 -0500
Received: by mail-pb0-f54.google.com with SMTP id un15so4066723pbc.13
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 11:43:22 -0800 (PST)
In-Reply-To: <20131208123526.GA10037@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 8 Dec 2013 14:35:26 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Thu, Dec 05, 2013 at 03:20:52PM -0800, Stephen Hemminger wrote:
> > 
> > The virtio_net driver never sends the second address list to
> > the host. This is because send command takes a pointer to scatter list
> > to send but only inserts that one entry into the scatter list that
> > is sent to the host.
> > 
> > This bug has been there since:
> > commit f565a7c259d71cc186753653d978c646d2354b36
> > Author: Alex Williamson <alex.williamson@hp.com>
> > Date:   Wed Feb 4 09:02:45 2009 +0000
> > 
> >     virtio_net: Add a MAC filter table
> > 
> > 
> > I also dropped the in argument since it is never used.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> Indeed. Good catch.
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> but I think this needs to be submitted formally
> without the RFC tag for dave to include it.
> 
> It's also needed for stable I think?
> 

Not sure if anyone was actually using it. Don't like to put things to stable
unless people are seeing bug. It could be that doing this would breaks some
incorrect host implementation of virtio that was assuming original behaviour.
