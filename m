From: "Octavian Purdila" <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v5 2/3] sysctl: add proc_do_large_bitmap
Date: Sun, 21 Feb 2010 13:42:13 +0200
Message-ID: <1266752533.3428.28.camel@Nokia-N900-42-11>
Reply-To: <opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Linux Kernel Network Developers" <netdev@vger.kernel.org>,
	"Linux Kernel Developers" <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "Cong Wang" <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:18706 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751485Ab0BULk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2010 06:40:56 -0500
Content-ID: <1266752532.3428.27.camel@Nokia-N900-42-11>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> My test shows it still accepts spaces, e.g.
>
> echo '50000 50003 50005' > ip_local_reserved_ports
>
> works same as
>
> echo '50000,50003,50005' > ip_local_reserved_ports
>
> Is this expected? We will only accept commas, right?
>

Thanks for testing, I didn't saw that comming! I wanted to allow whitespaces in between the commas but it looks like I got overzealous. I can easily fix that. 

But I think its worth to keep the whitespaces in beetween, e.g. allow

$ echo '1, 2 ,3 ' >   ip_local_reserved_ports.

>
> Also, if I write an invalid value, it does reject this, but the previous
> value in that file is cleared, shouldn't we keep the previous one?
>
>

The only way I see to fix this is to return EINVAL if we detect a write with offset.

IMO we should do that for the other proc write routines as well, as otherwise ther result is confusing, e.g.

write("1 2"); write(" 3");

will set first value in the vector to 1, than second value to 2 then *first* value to 3.

I am all for it, but again, this changes userspace ABI. 
