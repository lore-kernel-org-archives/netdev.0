From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Mon, 01 Feb 2010 05:35:52 -0500
Message-ID: <1265020552.7499.147.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:53360 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157Ab0BAKgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 05:36:04 -0500
In-Reply-To: <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-01 at 11:36 +0200, Alexey Dobriyan wrote:
> On Mon, Feb 1, 2010 at 11:32 AM, Jon Masters <jonathan@jonmasters.org> wrote:
> > I hacked up a per-namespace version of hashtables (this needs doing
> > anyway, since the global stuff is just waiting to break)
> 
> Which ones? Conntrack hashtables are per-netns.

They are, but the metadata is not. Sorry for not being clear, but my
previous mail was. i.e. there is a per-netns hashtable that is indexed
using a global that might change at any time underneath. The htable size
and max should be per-netns too.

An existing sysctl/module parameter affects these and should also
ultimately either iterate through namespaces, or only affect the global
init_net (as it almost does now, except it changes the data used by the
others and doesn't resize them).

Jon.


