From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/2] bridge: make setlink/dellink notifications
 more accurate
Date: Thu, 19 Oct 2017 19:10:11 +0300
Message-ID: <01c5bff2-cb5d-2b52-b11b-d6c2e1ab52a8@cumulusnetworks.com>
References: <1508428499-32355-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        mrv@mojatatu.com, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:55882 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752662AbdJSQKP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 12:10:15 -0400
Received: by mail-wm0-f65.google.com with SMTP id u138so17556400wmu.4
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 09:10:14 -0700 (PDT)
In-Reply-To: <1508428499-32355-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/10/17 18:54, Nikolay Aleksandrov wrote:
> Hi,
> Before this set the bridge would generate a notification on vlan add or del
> even if they didn't actually do any changes, which confuses listeners and
> is generally not preferred. We could also lose notifications on actual
> changes if one adds a range of vlans and there's an error in the middle.
> The problem with just breaking and returning an error is that we could
> break existing user-space scripts which rely on the vlan delete to clear
> all existing entries in the specified range and ignore the non-existing
> errors (typically used to clear the current vlan config).
> So in order to make the notifications more accurate while keeping backwards
> compatibility we add a boolean that tracks if anything actually changed
> during the config calls.
> 
> The vlan add is more difficult to fix because it always returns 0 even if
> nothing changed, so we use EEXIST to signal that and in order not to break
> overlapping vlan range add or script return expectations we clear it on
> return, the functions used by vlan add are not expected to return EEXIST.
> 
> Thanks,
>  Nik
> 
> Nikolay Aleksandrov (2):
>   bridge: netlink: make setlink/dellink notifications more accurate
>   bridge: vlan: return EEXIST on add if nothing changed
> 
>  net/bridge/br_netlink.c        | 49 ++++++++++++++++++++++++++----------------
>  net/bridge/br_netlink_tunnel.c | 14 +++++++-----
>  net/bridge/br_private_tunnel.h |  3 ++-
>  net/bridge/br_vlan.c           | 38 +++++++++++++++++++++-----------
>  4 files changed, 68 insertions(+), 36 deletions(-)
> 

Self-NAK
Dave, please ignore this set and apologies for the noise.

I'd actually prefer to send "changed" down to vlan_add and vlan_del
to be set there instead of overloading EEXIST like that. It will be safer.

I'll wait for some comments about the rest of the change and will send
a v2.

Thanks,
 Nik
