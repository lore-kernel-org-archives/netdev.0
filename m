From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: really disable TPA if 'disable_tpa' option
 is set
Date: Mon, 27 Apr 2015 18:15:44 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63D2041C@AVMB1.qlogic.org>
References: <1430148038-25695-1-git-send-email-mschmidt@redhat.com>,<20150427.134323.156569796484222010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"mschmidt@redhat.com" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:36265 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964918AbbD0SP5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 14:15:57 -0400
In-Reply-To: <20150427.134323.156569796484222010.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> bnx2x's 'disable_tpa=1' module option is not respected properly and TPA
>> (transparent packet aggregation) remains enabled. Even though the
>> module option causes LRO to be disabled, TPA is enabled in GRO mode.
>>
>> Additionally, disabling GRO via ethtool then has no effect. One can
>> still observe tpa_* statistics increase and large packets being received
>> in tcpdump.
>>
>> The bug was an unintended consequence of commit aebf6244cd39 "bnx2x: Be
>> more forgiving toward SW GRO".
>>
>> Fix it by following the bp->disable_tpa flag when initializing fp's.
>>
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
>
>Applied, thanks.

Michal - thanks, but Dave -is it possible you gave us only 2.5 hours to
review this one?

I agree that this fixes an incorrect logic, but its incomplete as the bnx2x
'bp->flags' no longer represent the correct logic. I.e., it might cause
additional issues down the road, as the 'fp->mode' and 'fp->disable_tpa'
are no longer in sync.

We already have a fix for this issue, we just haven't sent it to 'net' yet.
Are you willing to give us an additional day to send an alternative fix?
Or do you prefer to take this, and possibly later we'll remove the logic
added by this patch in our own?
