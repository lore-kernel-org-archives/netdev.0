From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next v5 0/7] gtp: misc improvements
Date: Mon, 13 Mar 2017 19:45:55 +0100 (CET)
Message-ID: <1675883877.375949.1489430755546.JavaMail.zimbra@tpip.net>
References: <20170309164302.13550-1-aschultz@tpip.net> <20170313164812.GA31925@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: laforge <laforge@gnumonks.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        netdev <netdev@vger.kernel.org>
To: pablo <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:60399 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750808AbdCMSp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 14:45:59 -0400
In-Reply-To: <20170313164812.GA31925@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

----- On Mar 13, 2017, at 5:48 PM, pablo pablo@netfilter.org wrote:

> On Thu, Mar 09, 2017 at 05:42:55PM +0100, Andreas Schultz wrote:
>> Hi Pablo,
>> 
>> This is a resent of last series that missed the merge window. There
>> are no changes compared to v4.
>> 
>> v4: Compared to v3 it contains mostly smallish naming and spelling fixes.
>> It also drops the documentation patch, Harald did a better job with the
>> documentation and the some things I described do not yet match the
>> implementation.
>> I'll readd the relevant parts with a follow up series.
>> 
>> This series lays the groundwork for removing the socket references from
>> the GTP netdevice by removing duplicate code and simplifying the logic on
>> some code paths.
>> 
>> It slighly changes the GTP genl API by making the socket parameters optional
>> (though one of them is still required).
>> 
>> The removal of the socket references will break the 1:1 releation between
>> GTP netdevice and GTP socket that prevents us to support multiple VRFs with
>> overlapping IP addresse spaces attached to the same GTP-U entity (needed for
>> multi APN support, coming a follow up series).
>> 
>> Pablo found a socket hold problem in v2. In order to solve that I had to
>> switch the socket references from the struct socket to the internal
>> struct sock. This should have no functionl impact, but we can now hang
>> on to the reference without blocking user space from closing the GTP socket.
> 
> Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

Thanks, Pablo.
 
> I personally don't like this podge hodge unsorted submissions, I don't
> think they belong to the same series but you keep pushing with this
> patchset in this same way, which is annoying.

I don't think this a podge hodge series. There is a clear goal behind all
those changes and every patch is a step towards this. When I tried to
send the full series including the final change that ties everything
together, I got told that this was way too much. Now, that I split it into
a smaller series, I get told that there is no clear idea connecting those
changes.

Frankly, between the two options, I had no idea how else to submit this
work.

> In your follow up patchsets, please split them in smaller series that
> are related.

Now that the basic infrastructure changes are in place, the followup
changes are much more focused.

The IPv6 transport change might be challenge later one, but that will be
a separate series anyway.

> I would like you take the time to develop the VRF idea that you want
> to introduce, I just would like that we avoid bloating the GTP tunnel
> with features that we can just achieve via composite of different
> subsystems.

The VRF change is more about moving stuff around, it doesn't add much.
But you'll see that for yourself when I send the changes.

> Thank you.

Thank you,
Andreas
