From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 5/6] drivers: net: ethernet: cpts: implement cpts
 hardware clock
Date: Sat, 20 Oct 2012 15:43:31 +0200
Message-ID: <20121020134331.GA5444@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-6-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:46210 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754780Ab2JTNnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 09:43:43 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so1121533wib.1
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 06:43:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1350427518-7230-6-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I did a careful read of this driver, and I found a number of issues,
but I am not giving a line by line review, for reasons explained
below. For the most part, your driver is very similar to mine, and
your driver would probably work fine too, when given a bit of review
and revision. However, in the end, it would end up looking nearly
identical to mine.

The issues about which you have voiced concern (counter roll over,
changing input clock frequency) are by no means unique to the CPTS.
The existing PHC drivers all handle these issues in a way consistent
with each other. New drivers should not invent their own solutions to
such problems.

If I had never written a CPTS driver and had seen your present
submission first, then I would be willing to help you get your driver
merged. But in my view, this work is already done, and so I am favoring
my own driver at this point.

Here is my suggestion for moving forward with support the CPTS:

- It is too early to support the CPTS v1 found on the DM81xx, since
  the CPSW support (including DT) is totally lacking. Judging from
  your present driver and the TRM, the differences are minimal and
  will be easy to add later on. For now, we can simply check the
  version register for v2.

- If you can get the patches needed to get the CPSW working merged
  during the present v3.7-rc interval, that would form a basis for
  getting the CPTS into v3.8. I tried to post the patches that I had
  collected, but I failed to get them all accepted. I really don't
  know the issues surrounding those patches at all, and so I would
  appreciate if you would take the lead and get this support merged.

- I will add a version check for CPTS v2 and integrate your CPSW
  multicast patch (and anything else you think is missing) into my own
  patch series. Once your background patches have appeared, I will
  post the CPTS series for net-next, in time for v3.8.

- Looking ahead, once you get a patch series to fully support the
  DM81xx CPSW, we can patch the CPTS too.

Thanks,
Richard
