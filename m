From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/7] gtp: misc improvements
Date: Mon, 13 Mar 2017 13:06:52 -0700 (PDT)
Message-ID: <20170313.130652.118680417397625023.davem@davemloft.net>
References: <20170309164302.13550-1-aschultz@tpip.net>
        <20170313164812.GA31925@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aschultz@tpip.net, laforge@gnumonks.org,
        osmocom-net-gprs@lists.osmocom.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55630 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbdCMUGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 16:06:54 -0400
In-Reply-To: <20170313164812.GA31925@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 13 Mar 2017 17:48:12 +0100

> On Thu, Mar 09, 2017 at 05:42:55PM +0100, Andreas Schultz wrote:
>> Hi Pablo,
>> 
>> This is a resent of last series that missed the merge window. There
>> are no changes compared to v4.
>> 
>> v4: Compared to v3 it contains mostly smallish naming and spelling fixes.
>> It also drops the documentation patch, Harald did a better job with the
>> documentation and the some things I described do not yet match the implementation.
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
> 
> I personally don't like this podge hodge unsorted submissions, I don't
> think they belong to the same series but you keep pushing with this
> patchset in this same way, which is annoying.
> 
> In your follow up patchsets, please split them in smaller series that
> are related.

Series applied, and I agree with Pablo.

If the best you can come up with for a Subject line in your series
header posting is "misc improvements" it absolutely means you are
putting unrelated changes together in a series and you need to refine
the submission such that only related changes are submitted together.

Then you can say "gtp: Adjust GTP socket handling", for example, in
your header posting of a 2 patch series that includes only patches
#1 and #2.

Then you patiently wait for that patch series to be accepted, and then
you can move onwards to the other aspects of this series.
