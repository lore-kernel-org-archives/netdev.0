From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Wed, 19 Dec 2012 08:17:49 -0800
Message-ID: <1355933869.21834.13.camel@edumazet-glaptop>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com>
	 <1355843525.9380.18.camel@edumazet-glaptop>
	 <1355844398.14620.254.camel@zakaz.uk.xensource.com>
	 <55633610.20121219123427@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:41921 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021Ab2LSQRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 11:17:52 -0500
Received: by mail-da0-f41.google.com with SMTP id e20so1009882dak.28
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 08:17:51 -0800 (PST)
In-Reply-To: <55633610.20121219123427@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-19 at 12:34 +0100, Sander Eikelenboom wrote:

> Hi Ian,
> 
> It ran overnight and i haven't seen the warn_once trigger.
> (but i also didn't with the previous patch)
> 

As I said, the miminum value to not trigger the warning was what Ian
patch was doing, but it was still a not accurate estimation.

Doing the real accounting might trigger slow transferts, or dropped
packets because of socket limits (SNDBUF / RCVBUF) being hit sooner.

So the real question was : If accounting for full pages, is your
applications run as smooth as before, with no huge performance
regression ?
