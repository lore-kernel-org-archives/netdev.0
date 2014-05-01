From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two
 guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Thu, 1 May 2014 14:49:45 +0100
Message-ID: <536250F9.7060405@citrix.com>
References: <395225650.20140430124506@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:20811 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063AbaEANts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 09:49:48 -0400
In-Reply-To: <395225650.20140430124506@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/14 11:45, Sander Eikelenboom wrote:
>      Another point would be: what *correctness* testing is actually done on the xen-net* patches ?
I can speak only about my patches: I have manually tested them for the 
usecases where they likely to make a difference, plus they went through 
Xenserver's full test suite several times.
>      As i suspect this is again about fragmented packets .. that doesn't seem to be included in any test case while it actually seems to be a case which is hard to get right...
Beware, there are frags and frag_list which are two entirely different 
things with confusing names. In netback case, frags are used to pass 
through large packets for a long time. frag_list is used only since my 
grant mapping patches, to handle older guests (see comment in 
include/xen/interface/io/netif.h for XEN_NETIF_NR_SLOTS_MIN)


Zoli
