From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: lockdep trace from rc2.
Date: Wed, 27 Feb 2008 12:44:47 +0100
Message-ID: <1204112688.3729.61.camel@johannes.berg>
References: <20080225022237.GA3907@codemonkey.org.uk>
	 (sfid-20080225_030310_285221_71C3F1B9)  <1203936384.13162.77.camel@johannes.berg>
	 (sfid-20080225_104637_163874_DCCB9677)
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49561 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbYB0Lo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 06:44:56 -0500
In-Reply-To: <1203936384.13162.77.camel@johannes.berg> (sfid-20080225_104637_163874_DCCB9677)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This should be a correct change afaict, unless tulip has more work
> structs than the media work.
> 
> @@ tulip_down
> -	flush_scheduled_work();
> +	cancel_work_sync(&tp->media_work);

Forgot to mention that the latter just makes sure the work won't run
afterwards, while the former also makes sure it has run if it was
scheduled. That might make a difference if this code assumes it will
run, although for tulip it doesn't looks to be the case.

johannes

