From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 26 Jun 2007 09:27:28 -0400
Message-ID: <1182864448.5186.34.camel@localhost>
References: <1182440388.5017.31.camel@localhost>
	 <1182475614.30969.102.camel@debian.sh.intel.com>
	 <1182790051.5184.29.camel@localhost>
	 <20070625.134741.129320846.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:7242 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbXFZN1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 09:27:33 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1768727wxc
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2007 06:27:32 -0700 (PDT)
In-Reply-To: <20070625.134741.129320846.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-25-06 at 13:47 -0700, David Miller wrote:

> tg3 uses 1/4:
> 
> #define TG3_TX_WAKEUP_THRESH(tp)		((tp)->tx_pending / 4)
> 

Sorry - meant tg3 uses a much higher value (default is 128) - say
relative to e1000 (default of 32).
My tests with batching on e1000 indicate 128 gives the best results
which is 1/2 if you look at it from tx ring size perspective. So i have
hardcoded it in the git tree.

> tp->tx_pending is the current configured ring size, configurable
> via ethtool.

Thats what e1000 needs as well - currently it hardcodes things.
I think ethtool is the way to go - I will update the batch tree with
that fix for e1000.
Back to the question: Do you recall how this number was arrived at? 
128 packets will be sent out at GiGe in about 80 microsecs, so from a
feel-the-wind-direction perspective it seems reasonable.

cheers,
jamal


