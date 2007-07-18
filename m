From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [Bugme-new] [Bug 8778] New: Ocotea board: kernel reports access of bad area during boot with DEBUG_SLAB=y
Date: Wed, 18 Jul 2007 01:34:25 -0700
Message-ID: <20070718083425.GA29722@gate.ebshome.net>
References: <bug-8778-10286@http.bugzilla.kernel.org/> <20070718005253.942f0464.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, bart.vanassche@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:33014 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799AbXGRIlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 04:41:08 -0400
Content-Disposition: inline
In-Reply-To: <20070718005253.942f0464.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 18, 2007 at 12:52:53AM -0700, Andrew Morton wrote:
> On Wed, 18 Jul 2007 00:07:50 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=8778
> > 
> >            Summary: Ocotea board: kernel reports access of bad area during
> >                     boot with DEBUG_SLAB=y

Slab debugging is probably the culprit here. I had similar problem 
couple of years ago, not sure something has changed since then, 
haven't checked.

When slab debugging was enabled it made memory allocations non L1 
cache line aligned. This is very bad for DMA on non-coherent cache 
arches (PPC440 is one of those archs).

I have a hack for EMAC which tries to "workaround" this problem:
	http://kernel.ebshome.net/emac_slab_debug.diff
which might help.

-- 
Eugene


