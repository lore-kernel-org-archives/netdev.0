From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH 00/24] TRILL implementation
Date: Wed, 24 Sep 2014 09:44:22 -0700
Message-ID: <20140924094422.2e710ead@urahara>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, william@gandi.net, f.cachereul@alphalink.fr
To: Ahmed Amamou <ahmed@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35267 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbaIXQoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 12:44:34 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so608049pad.0
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 09:44:33 -0700 (PDT)
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2014 17:51:56 +0200
Ahmed Amamou <ahmed@gandi.net> wrote:

> Hi,
> 
> We have been working on a TRILL implementation in the Linux kernel for some
> months now.  The code has been pushed here https://github.com/Gandi/ktrill.git
> along the way.  Attached a series of patch as a first proposition.  The code is
> not perfect and probably still lacks of improvements. It's a first request of
> comment in order to get some feedbacks. This code has been tested for some
> months now.
> 
> These patch tries to implement TRILL protocol RFC 6325.  As a First
> implementation, some RFC details are still not implemented.
> 
> We still need to fix these points: 
> - The use of rtnetlink instead of the actual netlink.
> - BPDU handling
> 
> Also some parts may not be fully linux compliant, so we are waiting for
> comments
> 
> In order to test theses patches please follow this small wiki download quagga
> (userland) from here https://github.com/Gandi/quagga.git compile it using these
> options ./bootstrap.sh && ./configure --localstatedir=/var/run/quagga
> --enable-isisd --enable-trilld --disable-ipv6 --disable-ospfd
> --disable-ospfclient --disable-ripd --disable-babeld --disable-bgpd && make &&
> make install
> 
> start zebra and trilld  $ zebra -f $ZEBRA_CONF -P 2121 -u quagga -d $ trilld -f
> $TRILLD_CONF -P 2021 -u quagga -d
> 
> configuration sample can be found here
> https://github.com/Gandi/quagga/blob/dev_trill/zebra/zebra.conf.sample and here
> https://github.com/Gandi/quagga/blob/dev_trill/isisd/trilld.conf.sample
> 
> 
> Finally you need to correctly configure bridge port 
> 
> For access port (native frames) echo 4 >
> /sys/class/net/<INTERFACE>/brport/trill_state For trunk port (trill frame and
> control frames) echo 8 > /sys/class/net/<INTERFACE>/brport/trill_state 
> 
> more detail can be found here: https://github.com/Gandi/ktrill/wiki NB: for port
> state github version has different flags as we did not take into consideration
> all port flag when implementing it

Is this patch series bisectable? does it build at each step?

Also, it seems when you build with trill you lose normal bridge functionality.
Whether kernel is doing bridge or rbridge has to be a runtime (not compile time)
choice on a per-bridge basis.
