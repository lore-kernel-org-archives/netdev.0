From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Configuring synchronous ethernet with ethtool?
Date: Sat, 4 Apr 2015 22:03:44 +0200
Message-ID: <20150404200344.GA4271@localhost.localdomain>
References: <20150317161128.GA8793@localhost.localdomain>
 <1428155950.11260.66.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33119 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbbDDUDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 16:03:50 -0400
Received: by wiax7 with SMTP id x7so727488wia.0
        for <netdev@vger.kernel.org>; Sat, 04 Apr 2015 13:03:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1428155950.11260.66.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 04, 2015 at 02:59:10PM +0100, Ben Hutchings wrote:
> The 'manual' setting matches terminology in IEEE 802.3 (section 40.5.2).
> There's no mention of 'preferred' there but perhaps this switch will
> claim to be a single-port if you say it should prefer slave mode.

Thanks for the reference.  The switch I was talking about has control
register 9 implemented exactly as described in 802.3, but the TRM
description of bit 9.10 adds the word "prefer".

> So, I like the idea but it should not be tied to SyncE only.

Something like this?

   | ethtool property        | effect             |
   |-------------------------+--------------------|
   | synce-mode = none       | 9.12 = 0           |
   | synce-mode = master     | 9.12 = 1, 9.11 = 1 |
   | synce-mode = slave      | 9.12 = 1, 9.11 = 0 |
   |                         |                    |
   | port-type = multiport   | 9.10 = 1           |
   | port-type = single-port | 9.10 = 0           |

Thanks,
Richard
   
