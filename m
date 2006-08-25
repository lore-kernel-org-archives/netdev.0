From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 0/4] VM deadlock prevention -v5
Date: Fri, 25 Aug 2006 17:52:04 +0200
Message-ID: <1156521124.23000.1.camel@twins>
References: <20060825153946.24271.42758.sendpatchset@twins>
	 <Pine.LNX.4.64.0608250849480.9083@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Indan Zupancic <indan@nul.nu>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:49899 "EHLO
	amsfep11-int.chello.nl") by vger.kernel.org with ESMTP
	id S1030192AbWHYP4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 11:56:47 -0400
To: Christoph Lameter <clameter@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608250849480.9083@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-25 at 08:51 -0700, Christoph Lameter wrote:
> On Fri, 25 Aug 2006, Peter Zijlstra wrote:
> 
> > The basic premises is that network sockets serving the VM need undisturbed
> > functionality in the face of severe memory shortage.
> > 
> > This patch-set provides the framework to provide this.
> 
> Hmmm.. Is it not possible to avoid the memory pools by 
> guaranteeing that a certain number of page is easily reclaimable?

We're not actually using mempools, but the memalloc reserve. Purely easy
reclaimable memory is not enough however, since packet receive happens
from IRQ context, and we cannot unmap pages in IRQ context.

