From: Edgar E Iglesias <edgar.iglesias@axis.com>
Subject: Re: ipv4 ipsec
Date: Wed, 1 Jun 2005 01:23:40 +0200
Message-ID: <20050531232340.GA4589@edgar.se.axis.com>
References: <20050531224717.GE4068@edgar.se.axis.com> <20050531.155642.38710400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050531.155642.38710400.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2005 at 03:56:42PM -0700, David S. Miller wrote:
> From: Edgar E Iglesias <edgar.iglesias@axis.com>
> Date: Wed, 1 Jun 2005 00:47:17 +0200
> 
> > Im not sure this is the correct list for ipsec issues, but shouldn't
> > the size check at the bottom of net/ipv4/esp4.c be the other way
> > around (2.6.11)?
> 
> You are right, good catch.  Luckily the size of esp_decap_data
> is exactly 20 bytes, so the incorrect test happens to be harmless.

mostly harmless..
But for gcc ports that create packed structs per default, it is 19
bytes.

> 
> > --- /usr/src/linux-2.6.11-gentoo-r8/net/ipv4/esp4.c     2005-05-11 10:05:03.000000000 +0200
> > +++ esp4.c      2005-06-01 00:38:55.000000000 +0200
> 
> Please porperly -p1 root your patch so I can apply it, and also
> please provide a "Signed-off-by: " line for yourself as well.
> 
> It may seem pointless for a one-line patch, but I want to get you
> and others into the habit of submitting patches properly in the
> future.

oh sorry, I hope I get it right this time :)

Best regards
-- 
        Programmer
        Edgar E Iglesias <edgar@axis.com> 46.46.272.1946

Signed-off-by: Edgar E Iglesias <edgar@axis.com>

---------
% diff -Naur linux-2.6.11-gentoo-r6/net/ipv4/esp4.c  linux-2.6.11-gentoo-r9/net/ipv4/esp4.c
--- linux-2.6.11-gentoo-r6/net/ipv4/esp4.c      2005-04-14 21:39:32.000000000 +0200
+++ linux-2.6.11-gentoo-r9/net/ipv4/esp4.c      2005-06-01 00:38:55.000000000 +0200
@@ -480,7 +480,7 @@
 {
        struct xfrm_decap_state decap;
 
-       if (sizeof(struct esp_decap_data)  <
+       if (sizeof(struct esp_decap_data)  >
            sizeof(decap.decap_data)) {
                extern void decap_data_too_small(void);
 
