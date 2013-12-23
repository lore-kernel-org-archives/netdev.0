From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Add warning with unnecessary parentheses in if
 statements
Date: Sun, 22 Dec 2013 17:02:55 -0800
Message-ID: <1387760575.22671.36.camel@joe-AO722>
References: <1387725972-10244-3-git-send-email-ogerlitz@mellanox.com>
	 <20131222.181202.168681767663560253.davem@davemloft.net>
	 <1387755159.22671.27.camel@joe-AO722>
	 <20131222.191400.620087948725635345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org, amirv@mellanox.com,
	yanb@mellanox.com, ast@plumgrid.com,
	Andy Whitcroft <apw@shadowen.org>
To: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0164.hostedemail.com ([216.40.44.164]:45363 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756362Ab3LWBDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 20:03:02 -0500
In-Reply-To: <20131222.191400.620087948725635345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using doubled parentheses in statements like "if ((foo == bar))"
is unnecessary or may be a sign of an intended single assignment
instead of a comparison.

Bleat a warning message on those uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
> > On Sun, 2013-12-22 at 18:12 -0500, David Miller wrote:
> >> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> >> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> >> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> >> > +	    (mdev->dev->caps.tunnel_offload_mode ==  MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> >> > +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> >> 
> >> Way too many parenthesis, this isn't LISP :-)
> > 
> > Is patchwork stuttering?
> 
> I edited it, I'm quoting all of the lines in your patch that add the
> "too many parenthsis" problem.

OK then.  Or's patch, not mine, but maybe this is useful...

(this also happened today with another nominal cleanup patch)

 scripts/checkpatch.pl | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 8f3aecd..29af02a 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3251,6 +3251,13 @@ sub process {
 			}
 		}
 
+# if statements using unnecessary parentheses - ie: if ((foo == bar))
+		if ($^V && $^V ge 5.10.0 &&
+		    $line =~ /\bif\s*\(\s*\(\s*$LvalOrFunc\s*$Compare\s*$LvalOrFunc\s*\)\s*\)/) {
+			WARN("UNNECESSARY_PARENTHESES",
+			     "Unnecessary parentheses\n" . $herecurr);
+		}
+
 # Return of what appears to be an errno should normally be -'ve
 		if ($line =~ /^.\s*return\s*(E[A-Z]*)\s*;/) {
 			my $name = $1;
