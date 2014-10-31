From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 8/8] net/mlx4_en: Extend checksum offloading by
 CHECKSUM COMPLETE
Date: Fri, 31 Oct 2014 15:57:24 +0200
Message-ID: <CAJ3xEMjMt=sbyp98iynzWpu27-6LLZX50Ba_srV=Yo7Cx1BX4w@mail.gmail.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	<1414685216-28907-9-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx-AvGkUAxq69pTFWoyiM1pdktofEz+o+hCDw=7SWjWtpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Jerry Chu <hkchu@google.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:44904 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760274AbaJaN5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 09:57:25 -0400
Received: by mail-ob0-f173.google.com with SMTP id wn1so5910295obc.4
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 06:57:24 -0700 (PDT)
In-Reply-To: <CA+mtBx-AvGkUAxq69pTFWoyiM1pdktofEz+o+hCDw=7SWjWtpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2014 at 1:59 AM, Tom Herbert <therbert@google.com> wrote:
> On Thu, Oct 30, 2014 at 9:06 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> From: Shani Michaeli <shanim@mellanox.com>
>>
>> When processing received traffic, pass CHECKSUM_COMPLETE status to the
>> stack, with calculated checksum for non TCP/UDP packets (such
>> as GRE or ICMP).

> This is very exciting work!

thanks, good to know...

> One question though, what would mlx4
> return in the case of a zero UDP checksum? (I assume this patch won't
> affect this case but would like to make sure).

This patch doesn't change any functionality w.r.t UDP or TCP packets,
only for IP protocols which are different from those two.

When VXLAN packets arrive with zero UDP checksum and the HW verified
the internal checksum we return CHECKSUM_UNNECESSARY, for other cases
(e.g UDP but not VXLAN) I'd like to have 2nd look.

Or.
