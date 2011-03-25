From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allow shifted address in smsc911x
Date: Fri, 25 Mar 2011 14:31:03 -0700 (PDT)
Message-ID: <20110325.143103.25112180.davem@davemloft.net>
References: <1301088437-31915-1-git-send-email-mathieu.poirier@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	lee.jones@linaro.org, patches@linaro.org, linus.walleij@linaro.org
To: mathieu.poirier@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57416
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755063Ab1CYVaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 17:30:24 -0400
In-Reply-To: <1301088437-31915-1-git-send-email-mathieu.poirier@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: mathieu.poirier@linaro.org
Date: Fri, 25 Mar 2011 15:27:17 -0600

> From: Alessandro Rubini <rubini@gnudd.com>
> 
> At least one device I'm using needs address shifting to access
> registers in the LAN9221 device (smsc911x driver).  This patch
> adds a shift parameter in platform_data. The feature must be
> enabled at configuration time, because shifting by a pdata
> parameter makes access slower in those devices where no shift is
> needed (I tested one, it was 20% slower).
> 
> If the platform data requests shifted access but the feature is
> unavailable, the probe method complains to the console. Board
> config files should set the configuration option when needed.
> 
> Signed-off-by: Alessandro Rubini <rubini@gnudd.com>
> Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>

Implement this at run time, keying off of a boolean or similar
in the platform data.

Implement a set of ops, one to do a PIO read one to do a PIO write,
and choose the set of ops appropriate for the device depending upon
the setting found in the platform device.
