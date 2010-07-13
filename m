From: Ofer Heifetz <oferh@marvell.com>
Subject: RE: Splice status
Date: Tue, 13 Jul 2010 17:40:14 +0300
Message-ID: <EE71107DF0D1F24FA2D95041E64AB9E8ED254E7C17@IL-MB01.marvell.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
 	<AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
 	<EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
 	<1278334254.2877.158.camel@edumazet-laptop>
 <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
 	<1278388580.2466.305.camel@edumazet-laptop>
 <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>
 	<EE71107DF0D1F24FA2D95041E64AB9E8ED254E7B66@IL-MB01.marvell.com>
 	<AANLkTimRXMivugXHJswrT5FA93PIjSjU-RneFKs1bkLL@mail.gmail.com>
 	<EE71107DF0D1F24FA2D95041E64AB9E8ED254E7BAB@IL-MB01.marvell.com>
 <AANLkTimZyIhl34NzAZXMNUEmGy0KFCBs_LMk5qSBwrF2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jens Axboe <axboe@kernel.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:31858 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929Ab0GMOlh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 10:41:37 -0400
In-Reply-To: <AANLkTimZyIhl34NzAZXMNUEmGy0KFCBs_LMk5qSBwrF2@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I profiled the splice iometer write run and noticed that blk_end_request_err is being called many times, it looks like a good candidate for the high iowait, need to debug the root cause for it.

-Ofer

-----Original Message-----
From: Changli Gao [mailto:xiaosuo@gmail.com] 
Sent: Tuesday, July 13, 2010 4:58 PM
To: Ofer Heifetz
Cc: Eric Dumazet; Jens Axboe; netdev@vger.kernel.org
Subject: Re: Splice status

On Tue, Jul 13, 2010 at 8:42 PM, Ofer Heifetz <oferh@marvell.com> wrote:
> Write and re-write numbers are in MBps.
> Iozone performs re-write meaning reads a chunk of data and writes it back, so basically the performance for this operation should be quiet high since kernel caches usage.
>
> I forgot to mention that I used EXT4 fs.

Maybe it is caused by this line in generic_file_splice_write():

                balance_dirty_pages_ratelimited_nr(mapping, nr_pages);

Please try to test it again without this line.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
