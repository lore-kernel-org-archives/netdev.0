From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 08/15] drivers: net: Drop unlikely before
 IS_ERR(_OR_NULL)
Date: Fri, 31 Jul 2015 15:39:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB71042@AcuExch.aculab.com>
References: <cover.1438331416.git.viresh.kumar@linaro.org>
 <ceb569d147977a4138a7dd334fe7b9b0efdac8ac.1438331416.git.viresh.kumar@linaro.org>
 <55BB8E7B.7050307@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	Wingman Kwok <w-kwok2@ti.com>
To: 'Murali Karicheri' <m-karicheri2@ti.com>,
	Viresh Kumar <viresh.kumar@linaro.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:65193 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbbGaPmj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 11:42:39 -0400
In-Reply-To: <55BB8E7B.7050307@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Murali Karicheri
> Sent: 31 July 2015 16:04
> On 07/31/2015 04:38 AM, Viresh Kumar wrote:
> > IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
> > is no need to do that again from its callers. Drop it.
> >
> 
> IS_ERR_OR_NULL() is defined as
> 
> static inline bool __must_check IS_ERR_OR_NULL(__force const void *ptr)
> {
>          return !ptr || IS_ERR_VALUE((unsigned long)ptr);
> }
> 
> So the unlikely() applies only to second part. Wouldn't that be a
> problem for optimization?

Ugg...

The unlikely() in IS_ERR_VALUE() is likely to stop the compiler
doing a single 'window' comparison for the range [-MAX_ERROR .. 0].
So you are likely to end up with 2 comparisons.
I suspect that:

	return IS_ERR_VALUE((unsigned long)ptr - 1);

would be a much better test.
(Ignoring the off-by-one for the highest error.)

	David
