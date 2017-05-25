From: Peter Dawson <petedaws@gmail.com>
Subject: Re: [PATCH net] ip6_tunnel, ip6_gre: fix setting of DSCP on
 encapsulated packets
Date: Fri, 26 May 2017 06:08:42 +1000
Message-ID: <20170526060842.4bd21054@udesktop>
References: <20170523143616.38116e8f@gmail.com>
        <20170525.121117.810915705354733044.davem@davemloft.net>
        <20170526054627.00dcdeeb@udesktop>
        <20170525.154914.1347048861561693629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170525.154914.1347048861561693629.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 May 2017 15:49:14 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> Still not correct, you need to use a "Fixes: " tag of the form:
> 
> Fixes: 90427ef5d2a4 ("ipv6: fix flow labels when the traffic class is non-0")
> 
> And it must appear of the first line of tags, before signoffs and acks,
> with no empty lines in between.

Here is my proposed commit message in full. Note that 
the "Fixes" line extends to 78 chars. Is this OK?
Thanks

This fix addresses two problems in the way the DSCP field is formulated
 on the encapsulating header of IPv6 tunnels.
Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=195661

1) The IPv6 tunneling code was manipulating the DSCP field of the
 encapsulating packet using the 32b flowlabel. Since the flowlabel is
 only the lower 20b it was incorrect to assume that the upper 12b
 containing the DSCP and ECN fields would remain intact when formulating
 the encapsulating header. This fix handles the 'inherit' and
 'fixed-value' DSCP cases explicitly using the extant dsfield u8 variable.

2) The use of INET_ECN_encapsulate(0, dsfield) in ip6_tnl_xmit was
 incorrect and resulted in the DSCP value always being set to 0.

Commit 90427ef5d2a4 caused the regression by masking out the flowlabel
 which exposed the incorrect the handling of the DSCP portion of the 
 flowlabel in ip6_tunnel and ip6_gre.

Fixes: 90427ef5d2a4 ("ipv6: fix flow labels when the traffic class is non-0")
Signed-off-by: Peter Dawson <peter.a.dawson@boeing.com>
