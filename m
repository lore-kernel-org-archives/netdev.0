From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net] garp: fix a NULL pointer dereference bug
Date: Mon, 04 Mar 2013 11:41:38 +0800
Message-ID: <1362368498.18110.1.camel@cr0>
References: <1362368217-30984-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bugs@syam.in, David Ward <david.ward@ll.mit.edu>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754872Ab3CDDlx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Mar 2013 22:41:53 -0500
In-Reply-To: <1362368217-30984-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-04 at 11:36 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> A NULL-deref bug was reported in:
> https://bugzilla.kernel.org/show_bug.cgi?id=54281
> when deleting a vlan interface:
> 
> # ip link  del em1.57
> BUG: unable to handle kernel NULL pointer dereference at (null)
> IP: [<ffffffffa03c356f>] garp_uninit_applicant+0x2f/0xd0 [garp]
> ...
> 
> This is probably app->pdu is NULL'ed in garp_pdu_rcv()
> in BH, while garp_uninit_applicant() only holds rtnl lock
> which is not enough to prevent this. 
> 
> OTOH, garp_pdu_queue() should ways be called with the spin lock.
> 
> 
> Reported-by: bugs@syam.in

I can't reproduce it locally, so please help to test it. I only did
compiling test.

Thanks!
