From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 16/16] sfc: Don't receive packets when the napi
 budget == 0
Date: Sat, 15 Mar 2014 11:54:53 -0700
Message-ID: <1394909693.9668.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871ty41dps.fsf_-_@xmission.com>
	 <87lhwcw9j9.fsf_-_@xmission.com>
	 <1394897014.15764.26.camel@deadeye.wl.decadent.org.uk>
	 <20140315.122912.1621610280186900725.davem@davemloft.net>
	 <1394904231.15764.34.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ebiederm@xmission.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:39572 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951AbaCOSy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 14:54:57 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so3917883pdi.33
        for <netdev@vger.kernel.org>; Sat, 15 Mar 2014 11:54:57 -0700 (PDT)
In-Reply-To: <1394904231.15764.34.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-03-15 at 17:23 +0000, Ben Hutchings wrote:

> The Solarflare hardware provides generic event queues for RX and TX
> completions, link changes, errors, etc.  The driver can't process TX
> completions without going through all the other events mixed in with
> them.
> 

ndo_poll_controller() could process all events, and queue incoming
packets through netif_rx().

Nobody cares about performance in this path.
