From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] vxlan: virtual extensible lan
Date: Thu, 04 Oct 2012 08:34:50 +0200
Message-ID: <1349332490.16011.16.camel@edumazet-glaptop>
References: <20121001223232.566037595@vyatta.com>
	 <20121001223254.349753999@vyatta.com>
	 <CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
	 <20121003210220.5e74aa5d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59785 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756747Ab2JDGe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 02:34:56 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so61191bkc.19
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2012 23:34:54 -0700 (PDT)
In-Reply-To: <20121003210220.5e74aa5d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-03 at 21:02 -0700, Stephen Hemminger wrote:

>
> Since port is always a pair, there is no need to restrict range, unless
> there was a broken firewall in the way. One bug there is that random32()
> can return 0 which is not a valid port number.  A better fallback
> would be a hash of the MAC header.

But using up to 65536 values for the port means that if vxlan traffic
crosses a statefull firewall (eg netfilter with conntrack), this might
need 65536 contexts/sessions.

So random32() is not needed.

What might be needed is additional parameters for a vxlan tunnel, to
give an optional range for the source port.
