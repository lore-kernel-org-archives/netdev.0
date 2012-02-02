From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: [PATCH] net/hyperv: fix the issue that large packets be dropped
 by bridge
Date: Thu, 2 Feb 2012 10:43:50 +0800
Message-ID: <CAPgLHd_Yjdpu5_QLOdQdzEuj=1TsGb20oyDORa+YMcyYjKmo2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: haiyangz@microsoft.com, kys@microsoft.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:62355 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754546Ab2BBCnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 21:43:51 -0500
Received: by qcqw6 with SMTP id w6so1120486qcq.19
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 18:43:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2012 03:28 AM, David Miller wrote:
> From: Wei Yongjun <weiyj.lk@gmail.com>
> Date: Mon, 30 Jan 2012 16:12:45 +0800
>
>> +	/*
>> +	 * Make sure we got a valid packet message, now total_data_buflen
>> +	 * should be the data packet size plus the trailer padding size
>> +	 */
>> +	if (pkt->total_data_buflen < rndis_pkt->data_len) {
>> +		netdev_err(dev->net_dev->ndev, "incoming packet message "
>> +			   "buffer overflow detected (got %u, min %u)"
>> +			   "...dropping this message!\n",
>> +			   pkt->total_data_buflen, rndis_pkt->data_len);
>> +		return;
>> +	}
> This is inappropriate.  Any logging message that is potentially remotely
> triggerable must at a minimum be rate limited.  But to be honest I'd
> much prefer a statistic counter for this kind of event, rather then
> a log message.
Maybe the badly described error message confuse you, this error can not be
triggered remotely, it is the RNDIS control messages, which is sent
between the host and the RNDIS device.

Remain this error message may help us to detect the host device driver
bugs or the netvsc ringbuffer bugs.

So how about to change the error message?

+	/*
+	 * Make sure we got a valid RNDIS message, now total_data_buflen
+	 * should be the data packet size plus the trailer padding size
+	 */
+	if (pkt->total_data_buflen < rndis_pkt->data_len) {
+		netdev_err(dev->net_dev->ndev, "rndis message buffer "
+			   "overflow detected (got %u, min %u)"
+			   "...dropping this message!\n",
+			   pkt->total_data_buflen, rndis_pkt->data_len);
+		return;
+	}


Regards
