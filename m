From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2] net: bcmgenet: Use correct I/O accessors
Date: Wed, 30 Aug 2017 11:39:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0069792@AcuExch.aculab.com>
References: <1504034731-31613-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "opendmb@gmail.com" <opendmb@gmail.com>,
        "jaedon.shin@gmail.com" <jaedon.shin@gmail.com>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:60857 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751332AbdH3LkA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 07:40:00 -0400
In-Reply-To: <1504034731-31613-1-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli
> Sent: 29 August 2017 20:26
> The GENET driver currently uses __raw_{read,write}l which means
> native I/O endian. This works correctly for an ARM LE kernel (default)
> but fails miserably on an ARM BE (BE8) kernel where registers are kept
> little endian, so replace uses with {read,write}l_relaxed here which is
> what we want because this is all performance sensitive code.
...
> +	if (IS_ENABLED(CONFIG_MIPS) && IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
> +		__raw_writel(value, offset);
> +	else
> +		writel_relaxed(value, offset);

How do you know that all BE MIPS that might have this driver have
the BE registers of your card?
(Or that all ARM BE systems have LE registers.)

If nothing else the driver code should be predicated on a
condition set by the kernel config that depends on the cpu build
rather than embedding that condition in a lot of drivers

	David
