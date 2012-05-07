From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: compare_ether_addr[_64bits]() has no ordering
Date: Mon, 07 May 2012 15:53:29 +0200
Message-ID: <1336398809.3752.2313.camel@edumazet-glaptop>
References: <1336397946.4325.27.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53276 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756147Ab2EGNxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 09:53:34 -0400
Received: by bkcji2 with SMTP id ji2so3703427bkc.19
        for <netdev@vger.kernel.org>; Mon, 07 May 2012 06:53:33 -0700 (PDT)
In-Reply-To: <1336397946.4325.27.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-07 at 15:39 +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> Neither compare_ether_addr() nor compare_ether_addr_64bits()
> (as it can fall back to the former) have comparison semantics
> like memcmp() where the sign of the return value indicates sort
> order. We had a bug in the wireless code due to a blind memcmp
> replacement because of this.
> 
> A cursory look suggests that the wireless bug was the only one
> due to this semantic difference.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  include/linux/etherdevice.h |   11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)

The right way to avoid this kind of problems is to change these
functions to return a bool
