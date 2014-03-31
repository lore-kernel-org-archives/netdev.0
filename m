From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 net-next] net: ptp: oki-semi: fix build dependency
Date: Mon, 31 Mar 2014 20:55:38 +0200
Message-ID: <20140331185538.GB7729@netboy>
References: <1396288941-23063-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:48350 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbaCaSzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 14:55:53 -0400
Received: by mail-wi0-f171.google.com with SMTP id q5so3885709wiv.4
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 11:55:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1396288941-23063-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 11:02:21AM -0700, Alexei Starovoitov wrote:

> Richard,
> thank you for suggestion.
> oki-semi depends on ptp, so it's cleaner to move ptp_classify_raw there,
> instead of making it unconditionally available in net/core
 
> Daniel,
> timestamping has its own copy of PTP_FILTER, since timestamping
> doesn't depend on ptp and I didn't want to add circular dependency,
> since some of ptp pieces depend on timestamping, but not the others

We don't really need two copies. As long as you are refactoring this,
why not reduce it to just one filter?

Something like

#if defined(CONFIG_PTP_1588_CLOCK) || defined(CONFIG_NETWORK_PHY_TIMESTAMPING)

... code here ...

#endif

could go into filter.c or somewhere else in the stack.

Thanks,
Richard
