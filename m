From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 12:00:15 -0500
Message-ID: <e599b008-07c5-3de1-3349-a088bc3b6b1e@pobox.com>
References: <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
 <baf5246d-9d8a-4029-6823-350ed561fd33@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>, hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-24 11:43 AM, Mark Lord wrote:
..
> But how does this ASCII data end up at offset zero of the rx buffer??
> Not possible -- this isn't even stale data, because only an rx_desc could
> be at that offset in that buffer.

Answering my own question here, I suspect it ends up there as a result
of overrunning the previous URB.  So I have updated the test copy of the driver
here now to check for that exact situation.  It's running now, but could take
hours or a day for the bug to occur again.

It seems I am being overly helpful here.

Perhaps I should have just stopped with the original regression report
(driver works in 3.12.xx, fails on all newer kernels, as a result of enabling
hardware checksums).

Had I left it there, one might reasonably expect the onus to be on the driver
developer to sort it out, with me providing retests of supplied patches as need be.

But I've gone WAY BEYOND that, even questioning the sanity of the platform on
which it is being used, just to avoid blaming a buggy USB dongle for some other issue.
And this is leading people to suspect that I really think the platform is buggy.

It isn't.   It's been running for years, with a variety of USB hardware attached,
and nary a problem.  Except with this r8152 dongle on kernels > 3.12.

So, yeah, the driver is fixed in our local tree, and has been for some time now.
I just was hoping that perhaps others might be interested in it too,
since the bug (whatever it is) corrupts data on the NFS server.

Cheers
