From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning
Date: Tue, 12 Jan 2010 09:02:02 -0800
Message-ID: <20100112090202.6adf2370@nehalam>
References: <20100112.000804.186755338.davem@davemloft.net>
	<20100112085633.GB6628@ff.dom.local>
	<20100112.014218.112731835.davem@davemloft.net>
	<20100112.025620.210305029.davem@davemloft.net>
	<20100112081513.0175d579@nehalam>
	<4B4CA42D.5020305@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	mikem@ring3k.org, flyboy@gmail.com, rjw@sisk.pl,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46312 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752082Ab0ALRCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 12:02:34 -0500
In-Reply-To: <4B4CA42D.5020305@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jan 2010 11:32:45 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> On 01/12/2010 11:15 AM, Stephen Hemminger wrote:
> > This code makes transmit path and transmit reset safer by:
> >    * adding memory barrier before checking available ring slots
> >    * reseting state of tx ring elements after free
> >    * seperate cleanup function from ring done function
> >    * removing mostly unused tx_next element
> >
> >
> >    
> Stephen,
> 
> Just want to confirm that this supersedes both of the patches I'm 
> currently running with:
> 
> 1. skb_may_pull
> 2. Nash patch

You want:
  1. AF_PACKET patch that makes sure skb is not modified after send
  2. This patch.
