From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,v2] ip6_tunnel, ip6_gre: fix setting of DSCP on
 encapsulated packets
Date: Fri, 26 May 2017 14:55:12 -0400 (EDT)
Message-ID: <20170526.145512.223731527027395555.davem@davemloft.net>
References: <20170523143616.38116e8f@gmail.com>
        <20170526063518.612f51f9@udesktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: petedaws@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43554 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933125AbdEZSzP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:55:15 -0400
In-Reply-To: <20170526063518.612f51f9@udesktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Dawson <petedaws@gmail.com>
Date: Fri, 26 May 2017 06:35:18 +1000

> This fix addresses two problems in the way the DSCP field is formulated
>  on the encapsulating header of IPv6 tunnels.
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=195661
> 
> 1) The IPv6 tunneling code was manipulating the DSCP field of the
>  encapsulating packet using the 32b flowlabel. Since the flowlabel is
>  only the lower 20b it was incorrect to assume that the upper 12b
>  containing the DSCP and ECN fields would remain intact when formulating
>  the encapsulating header. This fix handles the 'inherit' and
>  'fixed-value' DSCP cases explicitly using the extant dsfield u8 variable.
> 
> 2) The use of INET_ECN_encapsulate(0, dsfield) in ip6_tnl_xmit was
>  incorrect and resulted in the DSCP value always being set to 0.
> 
> Commit 90427ef5d2a4 ("ipv6: fix flow labels when the traffic class 
>  is non-0") caused the regression by masking out the flowlabel
>  which exposed the incorrect handling of the DSCP portion of the 
>  flowlabel in ip6_tunnel and ip6_gre.
> 
> Fixes: 90427ef5d2a4 ("ipv6: fix flow labels when the traffic class is non-0")
> Signed-off-by: Peter Dawson <peter.a.dawson@boeing.com>

Applied, thanks.
