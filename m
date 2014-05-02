From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [3.15-rc3] Bisected: xen-netback mangles packets
 between two guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Fri, 2 May 2014 15:00:40 +0100
Message-ID: <5363A508.1000602@citrix.com>
References: <395225650.20140430124506@eikelenboom.it> <536162D3.5080307@citrix.com> <94755525.20140501002553@eikelenboom.it> <53624E25.8040404@citrix.com> <1810270947.20140501155911@eikelenboom.it> <53626C39.3030304@citrix.com> <928229683.20140501193936@eikelenboom.it> <198418193.20140501213951@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
To: Sander Eikelenboom <linux@eikelenboom.it>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56521 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805AbaEBOAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2014 10:00:43 -0400
In-Reply-To: <198418193.20140501213951@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Let's see what that does different and if that gives an insight in what is going
>> wrong.
>
> The debug patch that i used is attached.
> Here is some of the output, skb->data_len size sometimes varies slightly as does skb->truesize (is that allowed to become > 64k ?).
Yes, truesize can be over 64K, as it includes the aligned size of the 
data itself (64k max), struct skbuff and struct shared_info.
However my calculation for the truesize might be wrong: I count all the 
frags as full sized pages (skb->truesize += i * PAGE_SIZE), but the last 
page is not necessarily used entirely by that frag.
I had the idea that truesize should include the size of the whole page 
as we reserved it with alloc_page for this skb, but it might not be true.
Btw. with you "skb->truesize -= nskb->data_len;" version truesize should 
end up around 128k, something entirely wrong. Can you try with 
"skb->truesize -= nskb->data_len;" in that line?
My repro env is underway in the meantime ...

Regards,

Zoli
