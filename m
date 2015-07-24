From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH V3 3/7] Drivers: hv: vmbus: add APIs to send/recv hvsock
 packet and get the r/w-ability
Date: Fri, 24 Jul 2015 11:57:01 +0530
Message-ID: <20150724062701.GA5525@sudip-PC>
References: <1437476293-6837-1-git-send-email-decui@microsoft.com>
 <87zj2pk3jf.fsf@vitty.brq.redhat.com>
 <4538264677374d43961c2d709afb1dd3@SIXPR30MB031.064d.mgd.msft.net>
 <20150722103546.GO5371@mwanda>
 <75f1792c788e418eaddc0d6b7e3381de@SIXPR30MB031.064d.mgd.msft.net>
 <20150723101057.GQ5371@mwanda>
 <20150723102449.GR5371@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dexuan Cui <decui@microsoft.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"stefanha@redhat.com" <stefanha@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34380 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbbGXG1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 02:27:14 -0400
Content-Disposition: inline
In-Reply-To: <20150723102449.GR5371@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 23, 2015 at 01:24:50PM +0300, Dan Carpenter wrote:
> On Thu, Jul 23, 2015 at 01:10:57PM +0300, Dan Carpenter wrote:
> > In this specific case, writing it as "if (ret != 0)" caused the bug.  If
> > we had written it as "if (ret) return ret;" then there are no zeroes so
> > wouldn't have been any temptation to return the zero instead of the ret.
> 
> I did a search to see if returning the zero instead of the ret was a
> common mistake and it seems like it might be.  I did:
> 
> grep 'if (ret != 0)' drivers/   -r -A1 -n | grep "return 0;" | perl -ne 's/.c-(\d+)-/.c:$1/; print'
> 
> drivers/gpu/drm/nouveau/nouveau_display.c:111                   return 0;
This is also ok, the function is supposed to return ret or-ed with the
relevant flags based on the scan position. It is considered error if 0
is returned (without any flag).

regards
sudip
