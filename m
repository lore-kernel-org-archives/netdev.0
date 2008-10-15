From: David Miller <davem@davemloft.net>
Subject: Re: decnet: Fix complier warning
Date: Wed, 15 Oct 2008 15:57:46 -0700 (PDT)
Message-ID: <20081015.155746.76808335.davem@davemloft.net>
References: <1224073160.25004.85.camel@quoit>
	<1224074238.3984.169.camel@achroite>
	<1224074435.25004.87.camel@quoit>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	ccaulfie@redhat.com
To: swhiteho@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50366
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753267AbYJOW6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 18:58:09 -0400
In-Reply-To: <1224074435.25004.87.camel@quoit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Whitehouse <swhiteho@redhat.com>
Date: Wed, 15 Oct 2008 13:40:35 +0100

> On Wed, 2008-10-15 at 13:37 +0100, Ben Hutchings wrote:
> > Or you could make this use offsetof().  Daring, I know, it's only been a
> > standard macro for nearly 20 years.
 >
> Yes, thats true. The whole set of code is rather suspect to say the
> least and I was going for the minimal fix. Its a long time since I last
> looked at this code so I don't remember exactly why it was done in that
> way,

I'm going to check in something like the following:

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 2f0ac3c..ba35258 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -152,7 +152,7 @@ static struct dn_dev_parms dn_dev_list[] =  {
 
 #define DN_DEV_LIST_SIZE ARRAY_SIZE(dn_dev_list)
 
-#define DN_DEV_PARMS_OFFSET(x) ((int) ((char *) &((struct dn_dev_parms *)0)->x))
+#define DN_DEV_PARMS_OFFSET(x) offsetof(struct dn_dev_parms, x)
 
 #ifdef CONFIG_SYSCTL
 
