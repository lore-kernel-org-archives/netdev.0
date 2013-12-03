From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v4 1/2] net: sched: tbf: fix calculation of max_size
Date: Mon, 02 Dec 2013 20:51:08 -0800
Message-ID: <1386046268.30495.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386041214-72744-1-git-send-email-yangyingliang@huawei.com>
	 <1386041214-72744-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:54395 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863Ab3LCEvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 23:51:10 -0500
Received: by mail-pa0-f50.google.com with SMTP id kl14so2405041pab.9
        for <netdev@vger.kernel.org>; Mon, 02 Dec 2013 20:51:09 -0800 (PST)
In-Reply-To: <1386041214-72744-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-03 at 11:26 +0800, Yang Yingliang wrote:

> +	if (qopt->rate.linklayer == TC_LINKLAYER_UNAWARE) {
> +		rtab = qdisc_get_rtab(&qopt->rate, tb[TCA_TBF_RTAB]);
> +		if (rtab) {
> +			qdisc_put_rtab(rtab);
> +			rtab = NULL;
> +		}
>  	}

Please make remove rtab use to make sure you dont leak a pointer.

	if (qopt->rate.linklayer == TC_LINKLAYER_UNAWARE)
	    qdisc_put_rtab(qdisc_get_rtab(&qopt->rate,
				          tb[TCA_TBF_RTAB]));


> +	if (qopt->peakrate.linklayer == TC_LINKLAYER_UNAWARE) {
> +		ptab = qdisc_get_rtab(&qopt->peakrate, tb[TCA_TBF_PTAB]);
> +		if (ptab) {
> +			qdisc_put_rtab(ptab);
> +			ptab = NULL;
> +		}

Same here for ptab
