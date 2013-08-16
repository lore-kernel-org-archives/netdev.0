From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/3] [RFC] TCP syncookies: slow down timer to mitigate
 spoofing attacks
Date: Fri, 16 Aug 2013 23:47:06 +0200
Message-ID: <20130816214706.GF5154@breakpoint.cc>
References: <520A3B4A.1050704@jakoblell.com>
 <20130815235743.GA25665@midget.suse.cz>
 <20130816000043.GA11950@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakob Lell <jakob@jakoblell.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34384 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753399Ab3HPWbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 18:31:48 -0400
Content-Disposition: inline
In-Reply-To: <20130816000043.GA11950@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:
> This patch slows down the timer used in syncookies from 1/60 Hz to 1/60/4 Hz
> so that at any moment only two differrent timer values can be accepted.
> As a result, 1 bit of sequence number entropy is gained.
> 
> This changes the maximum cookie age limit from 4 - 5 minutes to 4 - 8 minutes.

I think we should just cap at 2 minutes (i.e, accept 0 and 1 minute delta).

A cookie is not validated if the last syn overflow is more than 3
seconds in the past anyway.
