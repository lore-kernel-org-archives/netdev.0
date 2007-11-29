From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/4] Sysctl namespace support
Date: Thu, 29 Nov 2007 10:40:24 -0700
Message-ID: <m1odddc5mf.fsf@ebiederm.dsl.xmission.com>
References: <4742C73C.3010904@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Pavel Emelyanov <xemul@openvz.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:56780 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756542AbXK2RpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 12:45:23 -0500
In-Reply-To: <4742C73C.3010904@openvz.org> (Pavel Emelyanov's message of "Tue,
	20 Nov 2007 14:38:36 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currently the network namespace work has gotten about as far as we can
without the ability to make sysctls that are per network namespace.

The techniques we have been using for other namespace of examining
current and replacing the ctl_table.data field depending on the
namespace instance that current->nsproxy refers to are both ugly
and do not work for the network sysctls.

The case in handling the networking sysctls that does not work with
the existing ugly pointer munging techniques are directories like
/proc/sys/net/ipv4/conf/ and /proc/sys/net/ipv4/neigh/ whose contents
vary depending on the networking devices present in the network
namespace.

Adding support to the sysctl infrastructure to allow to register
a sysctl table for a particular instance of a particular namespace
removes the need for magic sysctl methods, and allows the use
of the techniques for managing dynamic sysctl tables used for years
in the network stack.



Herbert we need this infrastructure most in net-2.6.25 (as not having
it is a current bottleneck to further development of the network
namespace) so these patches are against net-2.6.25.

Andrew also need this infrastructure in -mm so that we can take
advantage of this new infrastructure when implementing other
namespaces.

So I expect the sane way to deal with this patchset is to merge into
both net-2.6.25 and -mm and then Andrew can drop or disable the
patches once he pulls bases -mm on a version of net-2.6.25 with
the changes.

Eric
