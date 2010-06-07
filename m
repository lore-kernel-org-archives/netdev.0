From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 2/2] mlx4: add dynamic LRO disable support
Date: Mon, 07 Jun 2010 16:51:49 +0800
Message-ID: <4C0CB325.2040704@redhat.com>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>	 <20100603034312.5305.61000.sendpatchset@localhost.localdomain>	 <1275568622.2870.89.camel@localhost>  <4C085D45.6040001@redhat.com> <1275661552.2095.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert.xu@redhat.com, nhorman@redhat.com,
	sgruszka@redhat.com, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61477 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424Ab0FGJhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 05:37:23 -0400
In-Reply-To: <1275661552.2095.13.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/10 22:25, Ben Hutchings wrote:
> On Fri, 2010-06-04 at 09:56 +0800, Cong Wang wrote:
>> On 06/03/10 20:37, Ben Hutchings wrote:
>>> On Wed, 2010-06-02 at 23:39 -0400, Amerigo Wang wrote:
>>>> This patch adds dynamic LRO diable support for mlx4 net driver.
>>>> It also fixes a bug of mlx4, which checks NETIF_F_LRO flag in rx
>>>> path without rtnl lock.
>>> [...]
>>>
>>> Is that flag test actually unsafe - and if so, how is testing num_lro
>>> any better?  Perhaps access to net_device::features should be wrapped
>>> with ACCESS_ONCE() to ensure that reads and writes are atomic.
>>>
>>
>> At least, I don't find there is any race with 'num_lro', thus
>> no lock is needed.
>
> In both cases there is a race condition but it is harmless so long as
> the read and the write are atomic.  There is a general assumption in
> networking code that this is the case for int and long.  Personally I
> would prefer to see this made explicit using ACCESS_ONCE(), but I don't
> see any specific problem in mlx4 (not that I'm familiar with this driver
> either).

Hmm, right, it seems mlx4_en_add() is async too.
I will pick your suggestion.


>
> Now that I look at the patch again, I see you're using a static (i.e.
> global) variable to 'back up' the non-zero (enabled) value of num_lro.
> This is introducing a bug!  The correct value is apparently set in
> mlx4_en_get_profile(); you would need to replicate that.
>

Oh, probably, but unfortunately 'num_lro' is static so only visible
in en_main.c.

Thanks!

