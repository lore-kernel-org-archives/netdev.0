From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Tue, 06 Sep 2011 09:39:42 -0700
Message-ID: <1315327182.2576.2985.camel@schen9-DESK>
References: <4E631032.6050606@intel.com>
	 <CA+icZUU25QMMCVT1VfF9XB0wrkppNmKQbHwoHDAQ-qV9bi+HqQ@mail.gmail.com>
	 <CAAM7YAk0csJLLVFF6KYA8vMG_BN6QDvmYvtnY0Sq7P=cBsuKfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sedat.dilek@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>
To: "Yan, Zheng" <zheng.z.yan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9017 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731Ab1IFQh0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 12:37:26 -0400
In-Reply-To: <CAAM7YAk0csJLLVFF6KYA8vMG_BN6QDvmYvtnY0Sq7P=cBsuKfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-09-04 at 16:23 +0800, Yan, Zheng wrote:
> On Sun, Sep 4, 2011 at 3:12 PM, Sedat Dilek <sedat.dilek@googlemail.com> wrote:
> > On Sun, Sep 4, 2011 at 7:44 AM, Yan, Zheng <zheng.z.yan@intel.com> wrote:
> >> Commit 0856a30409 (Scm: Remove unnecessary pid & credential references
> >> in Unix socket's send and receive path) introduced a use-after-free bug.
> >> It passes the scm reference to the first skb. Skb(s) afterwards may
> >> reference freed data structure because the first skb can be destructed
> >> by the receiver at anytime. The fix is by passing the scm reference to
> >> the very last skb.
> >>
> >
> > s/by passing/bypassing ?
> 
> No
> 

Maybe it is a clearer to say

The fix is by withholding the scm reference obtained at the beginning of
unix_stream_sendmsg via scm_send and pass it to the very last skb.

Tim
