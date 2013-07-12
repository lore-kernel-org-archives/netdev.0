From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] gre: Fix MTU sizing check for gretap tunnels
Date: Fri, 12 Jul 2013 01:11:16 +0000 (UTC)
Message-ID: <krnl3j$d9l$1@ger.gmane.org>
References: <20130711201152.8775.40579.stgit@ahduyck-hc1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:33220 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932287Ab3GLBLi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jul 2013 21:11:38 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UxRtV-0001en-I3
	for netdev@vger.kernel.org; Fri, 12 Jul 2013 03:11:33 +0200
Received: from 116.53.101.57 ([116.53.101.57])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 03:11:33 +0200
Received: from xiyou.wangcong by 116.53.101.57 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 03:11:33 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jul 2013 at 20:12 GMT, Alexander Duyck <alexander.h.duyck@intel.com> wrote:
> This change fixes an MTU sizing issue seen with gretap tunnels when non-gso
> packets are sent from the interface.
>
> In my case I was able to reproduce the issue by simply sending a ping of
> 1421 bytes with the gretap interface created on a device with a standard
> 1500 mtu.
>
> This fix is based on the fact that the tunnel mtu is already adjusted by
> dev->hard_header_len so it would make sense that any packets being compared
> against that mtu should also be adjusted by hard_header_len and the tunnel
> header instead of just the tunnel header.
>


This patch indeed fixes the performance problem I reported, nice work!

Thanks for the patch, Alexander!
