From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip6_tunnel, ip6_gre: fix setting of DSCP on
 encapsulated packets
Date: Wed, 17 May 2017 18:18:00 -0700
Message-ID: <20170517181800.07788dd8@xeon-e3>
References: <5fba416f3f644db2b1f51e54724ef6ba@XCH15-07-02.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "I-Dawson, Peter A" <Peter.A.Dawson@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35677 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753916AbdERBSK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 21:18:10 -0400
Received: by mail-pf0-f174.google.com with SMTP id n23so15490082pfb.2
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 18:18:09 -0700 (PDT)
In-Reply-To: <5fba416f3f644db2b1f51e54724ef6ba@XCH15-07-02.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 May 2017 01:11:01 +0000
"I-Dawson, Peter A" <Peter.A.Dawson@boeing.com> wrote:

> This fix addresses two problems in the way the DSCP field is formulated on the
>  encapsulating header of IPv6 tunnels.
> This fix addresses Bug 195661. https://bugzilla.kernel.org/show_bug.cgi?id=195661 
> 
> 1) The IPv6 tunneling code was manipulating the DSCP field of the encapsulating
>  packet using the 32b flowlabel. Since the flowlabel is only the lower 20b it
>  was incorrect to assume that the upper 12b containing the DSCP and ECN fields
>  would remain intact when formulating the encapsulating header. This fix
>  handles the 'inherit' and 'fixed-value' DSCP cases explicitly using the extant
>  dsfield u8 variable.
> 
> 2) The use of INET_ECN_encapsulate(0, dsfield) in ip6_tnl_xmit was incorrect
>  and resulted in the DSCP value always being set to 0.
> ---
>  net/ipv6/ip6_gre.c    | 18 ++++++++++--------
>  net/ipv6/ip6_tunnel.c | 28 +++++++++++++++++-----------
>  2 files changed, 27 insertions(+), 19 deletions(-)

This patch looks correct, but has trivial style issues like using spaces
instead of tabs and other junk.  Please run checkpatch.pl, look at the
results and resubmit.
