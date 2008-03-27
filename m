From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/5] [NET] NETNS: Omit seq_net_private->net without
 CONFIG_NET_NS.
Date: Thu, 27 Mar 2008 13:18:12 -0700
Message-ID: <20080327131812.4f6a1a21.akpm@linux-foundation.org>
References: <20080326.084434.91814180.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xemul@openvz.org, dlezcano@fr.ibm.com,
	brian.haley@hp.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki /
	 =?ISO-8859-1?Q?=5F=5F=5F=5F=5F=5F=5F=5F=5F?=
	 =?ISO-8859-1?Q?=5F=5F=5F?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60838 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756664AbYC0UTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 16:19:13 -0400
In-Reply-To: <20080326.084434.91814180.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Mar 2008 08:44:34 +0900 (JST)
YOSHIFUJI Hideaki / ____________  <yoshfuji@linux-ipv6.org> wrote:

> Without CONFIG_NET_NS, no namespace other than &init_net exists,
> no need to store net in seq_net_private.
> 

This breaks the allnoconfig build.

include/linux/seq_file.h: In function 'seq_file_net':
include/linux/seq_file.h:85: error: 'init_net' undeclared (first use in this function)

Please review Documentation/SubmitChecklist - it has useful stuff. 
allnoconfig is so fast there's little reason to not run it regularly.

And could we please get all that net-specific stuff out of seq_file.h? 
It's really not an appropriate place for it.  Thanks.
