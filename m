From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: (unknown)
Date: Sat, 22 Dec 2007 10:48:54 +0900
Message-ID: <11982881341104-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
To: davem@davemloft.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:50208 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbXLVBtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 20:49:01 -0500
Subject: 
In-Reply-To: 20071221151111.GA2466@gondor.apana.org.au
References: 20071221151111.GA2466@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [XFRM] Documentaion: Fix error example at XFRMOUTSTATEMODEERROR. (Re: [XFRM]: Fix outbound statistics.)

Hello,

On Fri, 21 Dec 2007 23:11:11 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Dec 21, 2007 at 11:25:00PM +0900, Masahide NAKAMURA wrote:
> >
> >	do {
> >		err = xfrm_state_check_space(x, skb);
> > -		if (err)
> > +		if (err) {
> > +			XFRM_INC_STATS(LINUX_MIB_XFRMOUTERROR);
> >			goto error_nolock;
> > +		}
> >  
> >		err = x->outer_mode->output(x, skb);
> > -		if (err)
> > +		if (err) {
> > +			XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATEMODEERROR);
> 
> BTW, none of our existing mode output functions actually return
> an error.  I noticed that the description for this field is actually
> "Transformation mode specific error, e.g. Outer header space is not
> enough".  This is slightly misleading as output header space is
> checked by xfrm_state_check_space so if there's an error that's
> where it'll show up.

Thanks for comment, Herbert.

I fix the documentation to remove "e.g. Outer header space is not enough"
from XFRMSTATEMODEERROR.
About error code from xfrm_state_check_space(), I still map it XFRMOUTERROR
(other errors) this time because I think the error here is not a length
error by protocol (e.g MTU related things) but an internal buffer management.

Any comments for the statistics are still welcomed.

David, please apply the following patch, too.


[XFRM] Documentaion: Fix error example at XFRMOUTSTATEMODEERROR.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 Documentation/networking/xfrm_proc.txt |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/xfrm_proc.txt b/Documentation/networking/xfrm_proc.txt
index ec9045b..53c1a58 100644
--- a/Documentation/networking/xfrm_proc.txt
+++ b/Documentation/networking/xfrm_proc.txt
@@ -60,7 +60,6 @@ XfrmOutStateProtoError:
 	Transformation protocol specific error
 XfrmOutStateModeError:
 	Transformation mode specific error
-	e.g. Outer header space is not enough
 XfrmOutStateExpired:
 	State is expired
 XfrmOutPolBlock:
-- 
1.4.4.2

