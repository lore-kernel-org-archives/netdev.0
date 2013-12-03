From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net v4 1/2] net: sched: tbf: fix calculation of max_size
Date: Tue, 3 Dec 2013 14:09:06 +0800
Message-ID: <529D7582.7010108@huawei.com>
References: <1386041214-72744-1-git-send-email-yangyingliang@huawei.com>	 <1386041214-72744-2-git-send-email-yangyingliang@huawei.com> <1386046268.30495.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:27303 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472Ab3LCGJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 01:09:16 -0500
In-Reply-To: <1386046268.30495.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/3 12:51, Eric Dumazet wrote:
> On Tue, 2013-12-03 at 11:26 +0800, Yang Yingliang wrote:
> 
>> +	if (qopt->rate.linklayer == TC_LINKLAYER_UNAWARE) {
>> +		rtab = qdisc_get_rtab(&qopt->rate, tb[TCA_TBF_RTAB]);
>> +		if (rtab) {
>> +			qdisc_put_rtab(rtab);
>> +			rtab = NULL;
>> +		}
>>  	}
> 
> Please make remove rtab use to make sure you dont leak a pointer.
> 
> 	if (qopt->rate.linklayer == TC_LINKLAYER_UNAWARE)
> 	    qdisc_put_rtab(qdisc_get_rtab(&qopt->rate,
> 				          tb[TCA_TBF_RTAB]));
> 
> 
>> +	if (qopt->peakrate.linklayer == TC_LINKLAYER_UNAWARE) {
>> +		ptab = qdisc_get_rtab(&qopt->peakrate, tb[TCA_TBF_PTAB]);
>> +		if (ptab) {
>> +			qdisc_put_rtab(ptab);
>> +			ptab = NULL;
>> +		}
> 
> Same here for ptab
> 
OK, Thanks!

Regards,
Yang
