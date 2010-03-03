From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 1/8] net: add limit for socket backlog
Date: Wed, 03 Mar 2010 16:14:13 +0800
Message-ID: <1267604053.2370.102.camel@debian>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267599269.2839.84.camel@edumazet-laptop>
	 <1267601728.2370.47.camel@debian>
	 <1267603357.2839.105.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Per Liden <per.liden@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62879 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753518Ab0CCIM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 03:12:28 -0500
In-Reply-To: <1267603357.2839.105.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-03 at 16:02 +0800, Eric Dumazet wrote:
> > sk->sk_rcvbuf can be adjusted by setsockopt from user at run time.
> The
> > minimum allowed value is 256. I'm afraid this will break most
> protocols.
> 
> I see, then maybe use some offset in your test, to allow some extra
> space.
> 
> #define MINBACKLOG 2048
> 
> if (sk->sk_backlog.len >= (sk->sk_rcvbuf << 1) + MINBACKLOG)
>         return -ENOBUFS;

I want to provide a method for protocols to set its sock backlog limit.
For example, the sctp_rmem is 373500 (sysctl_sctp_rmem[1]) which is
larger than (sysctl_rmem_default << 1). But I'm not very sure about the
actual required size. So I didn't make it in the sctp patch. What do you
think?

Thanks,
-yi

