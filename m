From: Ben Greear <greearb@candelatech.com>
Subject: Re: netdev level filtering? perhaps pushing socket filters down?
Date: Thu, 16 Mar 2017 15:52:04 -0700
Message-ID: <58CB1714.8000305@candelatech.com>
References: <1489703635.3930.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Johannes Berg <johannes@sipsolutions.net>,
        netdev <netdev@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:51840 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752820AbdCPWmT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 18:42:19 -0400
In-Reply-To: <1489703635.3930.5.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2017 03:33 PM, Johannes Berg wrote:
> Hi all,
>
> Occasionally - we just had another case - people want to hook into
> packets received and processed by the mac80211 stack, but because they
> don't need all of them (e.g. not data packets), even adding a monitor
> interface and bringing it up has too high a cost because SKBs need to
> be prepared to send them to the monitor interface, even if no socket is
> consuming them.
>
> Ideally, we'd be able to detect that there are filter programs attached
> to the socket(s) that are looking at the frames coming in on the
> monitor interface, and we could somehow magically run those before we
> create a new SKB.
> One problem here is that we wouldn't really want to prepare all the
> radiotap header just to throw it away, so we'd have to be able to
> analyse the filter program to make sure it doesn't access anything but
> the radiotap header length, and that only in order to jump over it.
> That seems ... difficult, but we don't even know the header length -
> although we could fudge that and make a very long constant-size header,
> which might make it possible to do such analysis, or handle it by
> trapping on such access. But it seems rather difficult to implement
> this.
>
> The next best thing would be to install a filter program on the virtual
> monitor *interface* (netdev), but say that it doesn't get frames with
> radiotap, but pure 802.11 frames. We already have those in SKB format
> at this point, so it'd be simple to run such a program and only pass
> the SKB to the monitor netdev's RX when the program asked to do that.
>
> This now seems a bit like XDP, but for XDP this header difference
> doesn't seem appropriate either.
>
> Anyone have any other thoughts?

Attach at just above the driver, before it ever gets to stations/vdevs,
and ignore radiotap headers and/or add special processing for metadata like
rx-info?

Thanks,
Ben

>
> Thanks,
> johannes
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
