From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] SELinux: return -ECONNREFUSED from ip_postroute to
 signal	fatal error
Date: Wed, 17 Nov 2010 12:43:00 +0100
Message-ID: <4CE3BFC4.1010706@trash.net>
References: <20101116215238.6727.39248.stgit@paris.rdu.redhat.com> <20101116215257.6727.12163.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	selinux@tycho.nsa.gov, netfilter-devel@vger.kernel.org,
	equinox@diac24.net, eric.dumazet@gmail.com, davem@davemloft.net,
	hzhong@gmail.com, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	paul.moore@hp.com, pekkas@netcore.fi, sds@tycho.nsa.gov,
	yoshfuji@linux-ipv6.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43029 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934163Ab0KQLnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 06:43:05 -0500
In-Reply-To: <20101116215257.6727.12163.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.11.2010 22:52, Eric Paris wrote:
> The SELinux netfilter hooks just return NF_DROP if they drop a packet.  We
> want to signal that a drop in this hook is a permanant fatal error and is not
> transient.  If we do this the error will be passed back up the stack in some
> places and applications will get a faster interaction that something went
> wrong.

Looks good to me. I'd suggest to have these patches go through Dave's
tree since I want to make use of the netfilter error propagation
mechanism to return proper errno codes for netfilter re-routing
failures.
