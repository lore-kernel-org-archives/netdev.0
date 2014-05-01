From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY instead of copy" series.
Date: Thu, 1 May 2014 16:05:13 +0200
Message-ID: <1967602892.20140501160513@eikelenboom.it>
References: <395225650.20140430124506@eikelenboom.it> <536250F9.7060405@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:40412 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbaEAOFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 10:05:16 -0400
In-Reply-To: <536250F9.7060405@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, May 1, 2014, 3:49:45 PM, you wrote:

> On 30/04/14 11:45, Sander Eikelenboom wrote:
>>      Another point would be: what *correctness* testing is actually done on the xen-net* patches ?
> I can speak only about my patches: I have manually tested them for the 
> usecases where they likely to make a difference, plus they went through 
> Xenserver's full test suite several times.

I think Paul's patches for 3.14 also went through this testsuite fine, however 
it did have a bug in it. Does this testsuite include a test which causes a 
diverse pattern of frags (for both tx and rx case) ?


>>      As i suspect this is again about fragmented packets .. that doesn't seem to be included in any test case while it actually seems to be a case which is hard to get right...
> Beware, there are frags and frag_list which are two entirely different 
> things with confusing names. In netback case, frags are used to pass 
> through large packets for a long time. frag_list is used only since my 
> grant mapping patches, to handle older guests (see comment in 
> include/xen/interface/io/netif.h for XEN_NETIF_NR_SLOTS_MIN)

Ah ok .. it's not about the frags in the packets being handled, but the frag 
mechanism is supposed to be used internally ?

If so .. there is at least something wrong in the "older guest" detection,
because both dom0 and PV guests are running the same 3.15-rc3 kernel.



> Zoli
