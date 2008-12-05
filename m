From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] dccp: use roundup instead of opencoding
Date: Fri, 5 Dec 2008 23:53:41 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812052349380.3726@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0812052342180.3726@wrl-59.cs.helsinki.fi>
 <1228513664.3520.68.camel@achroite>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-659555435-1228513910=:3726"
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56539 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755961AbYLEVxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 16:53:42 -0500
In-Reply-To: <1228513664.3520.68.camel@achroite>
Content-ID: <Pine.LNX.4.64.0812052352430.4283@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-659555435-1228513910=:3726
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0812052352431.4283@wrl-59.cs.helsinki.fi>

On Fri, 5 Dec 2008, Ben Hutchings wrote:

> On Fri, 2008-12-05 at 23:43 +0200, Ilpo Järvinen wrote:
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > ---
> >  net/dccp/output.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/dccp/output.c b/net/dccp/output.c
> > index fea30cd..1b75ece 100644
> > --- a/net/dccp/output.c
> > +++ b/net/dccp/output.c
> > @@ -175,7 +175,7 @@ unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu)
> >  	 * make it a multiple of 4
> >  	 */
> >  
> > -	cur_mps -= ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
> > +	cur_mps -= roundup(5 + 6 + 10 + 6 + 6 + 6);
> 
> Maybe you should check that with your compiler.

Ah, sorry, I thought I'd made plenty of builds but sadly dccp wasn't 
included in any of them... Thanks for the alert. Added the missing , 4 
below.

-- 
 i.

[PATCH] dccp: use roundup instead of opencoding

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/dccp/output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/output.c b/net/dccp/output.c
index fea30cd..1b75ece 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -175,7 +175,7 @@ unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu)
 	 * make it a multiple of 4
 	 */
 
-	cur_mps -= ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
+	cur_mps -= roundup(5 + 6 + 10 + 6 + 6 + 6, 4);
 
 	/* And store cached results */
 	icsk->icsk_pmtu_cookie = pmtu;
-- 
1.5.2.2
---696208474-659555435-1228513910=:3726--
