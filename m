From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH net-next] Allow to set net namespace for wireless device
 via RTM_LINK
Date: Wed, 24 Dec 2014 11:48:48 +0200
Message-ID: <CAMw6YJKLWQmT-fqg1QLDHbCxnpxWyJUSX+wvOB_pFyE=8HfSfQ@mail.gmail.com>
References: <1410467723-2550-1-git-send-email-vadim4j@gmail.com>
	<1411075535.2034.5.camel@jlt4.sipsolutions.net>
	<20141014121627.GA5115@angus-think.lan>
	<1413798437.10246.12.camel@jlt4.sipsolutions.net>
	<128188DF-5A9B-47A5-8A89-974CF7CF9064@holtmann.org>
	<1413802344.10246.20.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:53805 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaLXJst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 04:48:49 -0500
In-Reply-To: <1413802344.10246.20.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2014 at 1:52 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Mon, 2014-10-20 at 12:46 +0200, Marcel Holtmann wrote:
>
>> Maybe relaxing the check and allow ip link to move a wireless netdev
>> into a namespace (and having the wiphy follow) could be allowed if it
>> is the only netdev or the original wlan0 that each wiphy creates. I
>> really do not know if this is worth it, but for some simpler container
>> cases it could be beneficial if RTNL can be used instead of having to
>> go through nl80211.
>
> The thought crossed my mind, but
>
> 1) it's relatively complex, though by no means impossible
> 2) it still moves more than you bargained for, since in theory the wiphy
> could be
>    used to create new interfaces etc.
>
> That said, I'm much more inclined to believe such a patch would be
> worthwhile than the original.
>
> johannes
>

Hi Johannes,

What about the following thoughts:

    1) Set NETIF_F_NETNS_LOCAL for phy wireless device only if there
is at least one virtual interface which was created on it
    2) What about to inherit netns for newer created interfaces from
the phy device ?

Thanks,
