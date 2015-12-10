From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net-next.git) 13/18] stmmac: perf, remove modulo in stmmac_rx()
Date: Thu, 10 Dec 2015 06:51:23 +0100
Message-ID: <566912DB.5010000@st.com>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com> <1449650274-14896-14-git-send-email-peppe.cavallaro@st.com> <063D6719AE5E284EB5DD2968C1650D6D1CBE9BB2@AcuExch.aculab.com> <5669096B.6050505@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "alexandre.torgue@st.com" <alexandre.torgue@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:34759 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751041AbbLJFvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 00:51:50 -0500
In-Reply-To: <5669096B.6050505@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2015 6:11 AM, Giuseppe CAVALLARO wrote:
> On 12/9/2015 6:21 PM, David Laight wrote:
>> From: Giuseppe Cavallaro
>>> Sent: 09 December 2015 08:38
>>> The indexes into the ring buffer are always incremented, and
>>> the entry is accessed via doing a modulo to find the "real" index.
>>> Modulo is an expensive operation.
>>>
>>> This patch replaces the modulo with a simple if clamp.
>>> It helps improve stmmac RX path as it's being called inside RX loop.
>>
>> Is dma_rx_size always a power of 2 ?
>
> no
>
>> If so you can replace the % by & and remove the conditionals.
>>
>> If you have changed the read and write values to indexes
>> then you need to be certain that the 'ring full' and 'ring empty'
>> cases are correctly distinguished.
>
> this is implicitly managed by dirty and curr index.

   ... also the dma will fail with unavailable buffer.

peppe
>
> thx
> peppe
>
>>
>>     David
>>
>
>
>
