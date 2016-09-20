From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] ipmr, ip6mr: return lastuse relative to now
Date: Tue, 20 Sep 2016 12:59:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0104872@AcuExch.aculab.com>
References: <1474362377-22627-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "sashok@cumulusnetworks.com" <sashok@cumulusnetworks.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: 'Nikolay Aleksandrov' <nikolay@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:54811 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751543AbcITNCY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 09:02:24 -0400
In-Reply-To: <1474362377-22627-1-git-send-email-nikolay@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov
> Sent: 20 September 2016 10:06
> When I introduced the lastuse member I made a subtle error because it was
> returned as an absolute value but that is meaningless to user-space as it
> doesn't allow to see how old exactly an entry is. Let's make it similar to
> how the bridge returns such values and make it relative to "now" (jiffies).
> This allows us to show the actual age of the entries and is much more
> useful (e.g. user-space daemons can age out entries, iproute2 can display
> the lastuse properly).
> 
...
> +			      jiffies_to_clock_t(jiffies -
> +						 c->mfc_un.res.lastuse),

You probably need to ensure the 'age' isn't negative because
'lastuse' got updated after 'jiffies' was read and there was
a clock interrupt in the gap.

	David
