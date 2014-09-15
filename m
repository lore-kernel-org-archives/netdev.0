From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH v2] zd1211rw: replace ZD_ASSERT with lockdep_assert_held()
Date: Mon, 15 Sep 2014 16:02:04 +1000
Message-ID: <CAGRGNgWOkzbu7sUxOqpgK_rzw1Xzny4aVFYOO6Rqd09-CpfvJA@mail.gmail.com>
References: <1410418407.1825.0.camel@jlt4.sipsolutions.net>
 <1410430179-19944-1-git-send-email-sanjeev_sharma@mentor.com>
 <1410430345.22863.0.camel@jlt4.sipsolutions.net> <FDC088D3B5555644AE135ED28A7ABDE94DF5256D@EU-MBX-02.mgc.mentorg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"dsd@gentoo.org" <dsd@gentoo.org>,
	"kune@deine-taler.de" <kune@deine-taler.de>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Sharma, Sanjeev" <Sanjeev_Sharma@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:46037 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbaIOGCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 02:02:25 -0400
In-Reply-To: <FDC088D3B5555644AE135ED28A7ABDE94DF5256D@EU-MBX-02.mgc.mentorg.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sanjeev,

On Thu, Sep 11, 2014 at 8:36 PM, Sharma, Sanjeev
<Sanjeev_Sharma@mentor.com> wrote:
> -----Original Message-----
> From: Johannes Berg [mailto:johannes@sipsolutions.net]
> Sent: Thursday, September 11, 2014 3:42 PM
> To: Sharma, Sanjeev
> Cc: dsd@gentoo.org; kune@deine-taler.de; linux-wireless@vger.kernel.org; linux-kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [PATCH v2] zd1211rw: replace ZD_ASSERT with lockdep_assert_held()
>
> On Thu, 2014-09-11 at 15:39 +0530, Sanjeev Sharma wrote:
>> on some architecture spin_is_locked() always return false in
>> uniprocessor configuration and therefore it would be advise to replace
>> with lockdep_assert_held().
>>
>> Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
>> ---
>> Changes in v2:
>>   - corrected the typo
>
>> Now it compiles, but you got the logic wrong.
>
>> +++ b/drivers/net/wireless/zd1211rw/zd_mac.c
>> @@ -235,7 +235,7 @@ void zd_mac_clear(struct zd_mac *mac)  {
>>       flush_workqueue(zd_workqueue);
>>       zd_chip_clear(&mac->chip);
>> -     ZD_ASSERT(!spin_is_locked(&mac->lock));
>> +     lockdep_assert_held(&mac->lock);
>>       ZD_MEMCLEAR(mac, sizeof(struct zd_mac));  }
>
>>Look closely at this again.
>
> I didn't understand where I  put wrong logic  ?

I find it helps to spell out what code is doing in words.

E.g. the line you're removing is:
ZD_ASSERT(!spin_is_locked(&mac->lock));

So, we'll assert when spin_is_locked(&mac->lock) is false, i.e. when
mac->lock is not spin locked.

This isn't the same as what you're replacing it with.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
