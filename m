From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] net: ovs: use CRC32 accelerated flow hash if available
Date: Tue, 10 Dec 2013 13:27:28 -0800
Message-ID: <CA+mtBx_FPUf=K=tBKmwe8-r7OsgiMS8VE6bYpyQa+OY7Cn=MaQ@mail.gmail.com>
References: <1386669178-14450-1-git-send-email-ffusco@redhat.com>
	<CAEP_g=_t750s50-F7A_hWD_yNs3MnKWN8WDBjzgoF8Mu+28Wyw@mail.gmail.com>
	<20131210.143652.1279430126319061689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesse Gross <jesse@nicira.com>, ffusco@redhat.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	dev@openvswitch.org, Daniel Borkmann <dborkman@redhat.com>,
	tgraf@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:65036 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740Ab3LJV13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 16:27:29 -0500
Received: by mail-ie0-f170.google.com with SMTP id qd12so9773178ieb.29
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 13:27:29 -0800 (PST)
In-Reply-To: <20131210.143652.1279430126319061689.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 11:36 AM, David Miller <davem@davemloft.net> wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Tue, 10 Dec 2013 11:28:08 -0800
>
>> I think this is definitely a good optimization to do given that so
>> much of the work that OVS does is hashing. However, isn't there a
>> library where there would be a more appropriate place to put this?
>
> I also honestly don't see why we want to special case OVS at all
> here.  This faster hashing would be useful for socket demux and
> other locations in the kernel.
>

Also, we already do a lot of work to compute flow hashes for packets
in both TX and RX.  Can these be leveraged? For instance, if OVS is
computing a 5-tuple hash on an RX packet it's probably redundant to
skb->rxhash.

> When I see changes like this my only reaction is "sad face".
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
