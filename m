From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH 3/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:44:41 -0500
Message-ID: <20101112014441.GA6804@canuck.infradead.org>
References: <1289524023.5167.67.camel@dan>
 <20101112012039.GB4683@canuck.infradead.org>
 <1289525049.5167.82.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	James Morris <jmorris@namei.org>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Tejun Heo <tj@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Li Zefan <lizf@cn.fujitsu.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Eme
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:38258 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114Ab0KLBp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:45:27 -0500
Content-Disposition: inline
In-Reply-To: <1289525049.5167.82.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 11, 2010 at 08:24:09PM -0500, Dan Rosenberg wrote:
> > If we really have to do this. At least don't duplicate all this code. Do
> > the check in the printf argument:
> > 
> > 	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
> > 		...
> > 		capable(CAP_NET_ADMIN) ? sp : 0,
> > 
> > I would even move the decision whether to expose kernel addresses or not
> > to a function so we can change behavior in one place.
> 
> I wrote it this way because the format specifier must also be changed,
> or the %p output will print "(null)", which cannot be parsed by
> userspace programs expecting "(nil)" or 0.  I could include another
> check inside the format specifier, but that seemed pretty ugly.  But
> then again, it's ugly either way.

Considering the amount of duplication you are about to do, you may
want to think about adding a new pointer format extension then. We
already have special '%p' modes for IPv6 addresse, MAC addresses and
various other pointer types. It wouldn't be hard to add one which
does not print (null).
