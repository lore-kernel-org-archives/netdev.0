From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
	submit  to upper layer
Date: Mon, 16 Mar 2009 11:20:37 +0800
Message-ID: <1237173637.2567.566.camel@ymzhang>
References: <1236761624.2567.442.camel@ymzhang>
	 <877i2wfh1l.fsf@basil.nowhere.org> <1236845792.2567.484.camel@ymzhang>
	 <1236866906.3221.11.camel@achroite> <1236926602.2567.528.camel@ymzhang>
	 <65634d660903131006n44f068dw18b2fe9dce25399e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:10140 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751375AbZCPDVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 23:21:22 -0400
In-Reply-To: <65634d660903131006n44f068dw18b2fe9dce25399e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-03-13 at 10:06 -0700, Tom Herbert wrote:
> On Thu, Mar 12, 2009 at 11:43 PM, Zhang, Yanmin
> <yanmin_zhang@linux.intel.com> wrote:
> >
> > On Thu, 2009-03-12 at 14:08 +0000, Ben Hutchings wrote:
> > > On Thu, 2009-03-12 at 16:16 +0800, Zhang, Yanmin wrote:
> > > > On Wed, 2009-03-11 at 12:13 +0100, Andi Kleen wrote:

> > > Yes, that's exactly what they do.  This feature is sometimes called
> > > Receive-Side Scaling (RSS) which is Microsoft's name for it.  Microsoft
> > > requires Windows drivers performing RSS to provide the hash value to the
> > > networking stack, so Linux drivers for the same hardware should be able
> > > to do so too.
> > Oh, I didn't know the background. I need study more about network.
> > Thanks for explain it.
> >
> 
> You'll definitely want to look at the hardware provided hash.  We've
> been using a 10G NIC which provides a Toeplitz hash (the one defined
> by Microsoft) and a software RSS-like capability to move packets from
> an interrupting CPU to another for processing.  The hash could be used
> to index to a set of CPUs, but we also use the hash as a connection
> identifier to key into a lookup table to steer packets to the CPU
> where the application is running based on the running CPU of the last
> recvmsg.
Your scenario is different from mine. My case is ip_forward which happens
in kernel and there is no application participating in the forwarding.

I might test the application communication on 10G NIC with my method later.


