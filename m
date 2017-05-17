From: "Baxter, Jim" <jim_baxter@mentor.com>
Subject: Re: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Wed, 17 May 2017 11:56:05 +0100
Message-ID: <b8114201-8beb-23ea-479a-9db006d4a668@mentor.com>
References: <1494956480-6127-1-git-send-email-jim_baxter@mentor.com>
 <1494956480-6127-2-git-send-email-jim_baxter@mentor.com>
 <87shk4fynp.fsf@miraculix.mork.no> <1495007060.30577.8.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>,
        =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:62464 "EHLO
        relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753553AbdEQK4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 06:56:11 -0400
In-Reply-To: <1495007060.30577.8.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum (oneukum@suse.com) Sent: Wed, 17 May 2017 09:44:20 +0200 

> Am Dienstag, den 16.05.2017, 20:24 +0200 schrieb Bjørn Mork:
>>
>> I must say that I don't like the additional complexity added here.  If
>> there are memory issues and you can reduce the buffer size to
>> USB_CDC_NCM_NTB_MIN_OUT_SIZE, then why don't you just set a lower tx_max
>> buffer size in the first place?
>>
>>   echo 2048 > /sys/class/net/wwan0/cdc_ncm/tx_max
>>

Hi

The issue is we need the higher performance for Mirrorlink to be able to
work correctly. The low memory situation only occurs very occasionally and
once the kernel has run compaction if this issue occurs again it will be
many hours later.

> 
> Hi,
> 
> that would hurt performance across the board though.
> Can we trigger memory compactation earlier?
> 
> 	Regards
> 		Oliver
> 

We initially tried increasing the vm.min_free_kbytes but the value needed to address
the problem was around 65536 which then meant some other applications were unable to
run due to there not being enough free memory.
The i.MX6 based system has 863MB of RAM in total.

Regards,
Jim
