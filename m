From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Tue, 06 Sep 2011 09:25:26 -0700
Message-ID: <1315326326.2576.2980.camel@schen9-DESK>
References: <4E631032.6050606@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33539 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751579Ab1IFQXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 12:23:10 -0400
In-Reply-To: <4E631032.6050606@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-09-04 at 13:44 +0800, Yan, Zheng wrote:
> Commit 0856a30409 (Scm: Remove unnecessary pid & credential references
> in Unix socket's send and receive path) introduced a use-after-free bug.
> It passes the scm reference to the first skb. Skb(s) afterwards may
> reference freed data structure because the first skb can be destructed
> by the receiver at anytime. The fix is by passing the scm reference to
> the very last skb.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> Reported-by: Jiri Slaby <jirislaby@gmail.com>
> ---

Thanks for finding this bug in my original patch.  I've missed the case
where receiving side could have released the all the references to the
credential before the send side is using the credential again for
subsequent skbs in the stream, thus causing the problem we saw.  Getting
an extra reference for pid/credentials at the beginning of the stream
and not getting reference for the last skb is the right approach.

Thanks also to Sedat, Valdis and Jiri for their extensive testing to
discover the bug and testing the subsequent fixes. 

Acked-by: Tim Chen <tim.c.chen@linux.intel.com>
