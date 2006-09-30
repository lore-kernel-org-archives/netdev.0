From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is
 present
Date: Sat, 30 Sep 2006 11:09:46 -0700
Message-ID: <1159639786.3741.52.camel@rh4>
References: <1159564053.3741.19.camel@rh4>  <451E434E.5040500@myri.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:36620 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751090AbWI3SNW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 14:13:22 -0400
To: "Brice Goglin" <brice@myri.com>
In-Reply-To: <451E434E.5040500@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-09-30 at 12:13 +0200, Brice Goglin wrote:

> What if the machine has such a bridge and board, but the board is not
> actually located somewhere behind the bridge? I would rather walk the
> PCI hierarchy from the board to the top and check whether we find a
> AMD8132. Probably something like:
> 

I have considered that.  I have PCI walking code like in tg3 to
determine if certain tg3 devices are behind some ICH or ServerWorks EPB
bridges.  The workaround needed in those cases have big impact on
performance and therefore it is important to determine exactly when to
apply those workarounds.

Here in this case, since the difference in performance between MSI and
INTA is very minor and almost negligible in a lot of cases, I decided to
keep it simple and just check for the presence of the 8132.

