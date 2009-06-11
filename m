From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2] net: Introduce recvmmsg socket syscall
Date: Thu, 11 Jun 2009 02:41:00 -0700 (PDT)
Message-ID: <20090611.024100.233245804.davem@davemloft.net>
References: <20090611034022.GC22424@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vanhoof@redhat.com, williams@redhat.com,
	caitlin.bestler@gmail.com, paul.moore@hp.com, steve@chygwyn.com,
	remi.denis-courmont@nokia.com, nhorman@tuxdriver.com,
	niv@us.ibm.com
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40550
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751581AbZFKJk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:40:58 -0400
In-Reply-To: <20090611034022.GC22424@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 11 Jun 2009 00:40:22 -0300

> +	struct compat_timespec *timeout_compat =
> +		(struct compat_timespec *)timeout;

In order for this to build on non-compat platforms, or when
CONFIG_COMPAT is disabled, you'll need to avoid trying to
reference compat_timespec.

We get away with compat_msghdr because we define it as a NOP
in net/compat.h when necessary.

Doing the same, and cleanly, with this non-networking compat knob is
unlikely to be straightforward.
