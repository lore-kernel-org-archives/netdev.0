From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] nl80211: fix attrbuf access race by allocating a separate
 one
Date: Wed, 19 Jun 2013 17:44:35 +0400
Message-ID: <51C1B5C3.8080604@cogentembedded.com>
References: <CA+55aFxOde8n0M2=77-TQ2Ea9iz8s-e8zGFwjj6RVyMFXBgxEA@mail.gmail.com>  <20130618.190632.33329016434510583.davem@davemloft.net>  <CA+55aFz=eG5-zh1toHxrx=4Qm4DvwyiBCU3u-6tc0-utfZ6xiA@mail.gmail.com>  (sfid-20130619_042459_700600_08CD35A3) <1371628488.8349.3.camel@jlt4.sipsolutions.net>  (sfid-20130619_095509_334897_6BA231FA) <1371630238.8349.6.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	John Linville <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:32904 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788Ab3FSNoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 09:44:34 -0400
Received: by mail-lb0-f180.google.com with SMTP id o10so4766808lbi.39
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 06:44:32 -0700 (PDT)
In-Reply-To: <1371630238.8349.6.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 19-06-2013 12:23, Johannes Berg wrote:

> From: Johannes Berg <johannes.berg@intel.com>

> Since my commit 3713b4e364, nl80211_dump_wiphy() uses the global

    Please also specify that commit's summary line in parens.

> nl80211_fam.attrbuf for parsing the incoming data. This wouldn't
> be a problem if it only did so on the first dump iteration which
> is locked against other commands in generic netlink, but due to
> space constraints in cb->args (the needed state doesn't fit) I
> decided to always parse the original message. That's racy though
> since nl80211_fam.attrbuf could be used by some other parsing in
> generic netlink concurrently.

> For now, fix this by allocating a separate parse buffer (it's a
> bit too big for the stack, currently 1448 bytes on 64-bit). For
> -next, I'll change the code to parse into the global buffer in
> the first round only and then allocate a smaller buffer to keep
> the state in cb->args.

> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

WBR, Sergei
