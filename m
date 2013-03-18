From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Mon, 18 Mar 2013 09:27:14 +0200
Message-ID: <1363591634.4752.10.camel@lb-tlvb-eilong.il.broadcom.com>
References: <CANP3RGdWMHv-7TZ4fvASrmz7NXkO7B2g2RCZwV8ecExUsQTQ2w@mail.gmail.com>
 <1363384577-21287-1-git-send-email-zenczykowski@gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F20BE6A2B@SJEXCHMB06.corp.ad.broadcom.com>
 <20130317.142425.1713640249735424829.davem@davemloft.net>
 <1363549074.4752.3.camel@lb-tlvb-eilong.il.broadcom.com>
 <1363551952.29475.93.camel@edumazet-glaptop>
 <1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
 <1363562251.29475.109.camel@edumazet-glaptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, dmitry@broadcom.com,
	zenczykowski@gmail.com, maze@google.com, netdev@vger.kernel.org,
	yuvalmin@broadcom.com
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2303 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106Ab3CRH3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 03:29:00 -0400
In-Reply-To: <1363562251.29475.109.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-17 at 16:17 -0700, Eric Dumazet wrote:
> On Sun, 2013-03-17 at 22:53 +0200, Eilon Greenstein wrote:
> 
> > This is not such a trivial issue - the HW/FW is guaranteeing the atomic
> > read and this is why we can always use 32b variables.
> > 
> 
> I am glad you qualify the following code as 'trivial'
> 

Eric - I did not mean that the solution is trivial, I meant that the
problem is trivial. Like the trivial statement that the code should not
contain any bugs :)


> All you really needed is to have normal host structures containing u64
> fields, and you only needed one single helper to convert from hw u32:u32
> to host u64.
> 
> Because gcc handles u64 operations very well, even on 32bit hosts, and
> it knows about the carry flag.

I was not clear when I said size-extension: most of the HW counters are
46bits and we are trying to keep 64bits counters in the SW, so simply
copying the data from the HW is not enough.
