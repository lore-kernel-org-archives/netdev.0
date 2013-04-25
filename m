From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH net-next 5/7] qlcnic: Rename the IRQ description.
Date: Thu, 25 Apr 2013 23:11:05 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E2FFBDB@avmb2.qlogic.org>
References: <1366848330.2600.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe002.messaging.microsoft.com ([207.46.163.25]:58054
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758712Ab3DYXLQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 19:11:16 -0400
In-Reply-To: <1366848330.2600.10.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Content-ID: <7DAA9A7199AF58488FC4A1E34E71E7F4@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 4/24/13 5:05 PM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:

>On Wed, 2013-04-24 at 18:42 -0400, Jitendra Kalsaria wrote:
>> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
>> 
>> Here's what modified vectors will look like
>> in the /proc/interrupts
>> 
>>         MSIx             	INTx
>> -----------------------------------------
>> 83xx    qlcnic[MB]
>> 	qlcnic-ethX[Rx0]
>> 	qlcnic-ethX[Rx1]
>> 	..
>> 	qlcnic-ethX[RxN]
>> 	qlcnic-ethx[Tx0]        qlcnic[MB+Tx0+Rx0]
>> 
>> 82xx    qlcnic-ethX[Rx0]
>> 	qlcnic-ethX[Rx1]
>> 	..
>> 	qlcnic-ethX[Tx0+RxN]    qlcnic-ethX[Tx0+Rx0]
>[...]
>
>Many other multiqueue drivers (including your own qlge) use these
>formats for IRQ handler names:

Thanks for the review. We will change the format in a future submission
according to your suggestion and similar to what other multiqueue drivers
are using.
>
>RX queue:   <device>-rx-<index>
>TX queue:   <device>-tx-<index>
>Queue pair: <device>-<index>

We will like to add the qlcnic prefix to the above format, as it makes it
easier for an end user to identify which driver these entries belongs to,
without having to run addition command.
This is how the format will look like:

       MSIx                    INTx
               -----------------------------------------
83xx   qlcnic-MB
       qlcnic-ethX-rx-0
       qlcnic-ethX-rx-1
       ..
       qlcnic-ethX-rx-N
       qlcnic-ethx-tx-0        qlcnic-MB-tx-0-rx-0
 
82xx   qlcnic-ethX-rx-0
       qlcnic-ethX-rx-1
       ..
       qlcnic-ethX-tx-0-rx-N   qlcnic-ethX-tx-0-rx-0

Thanks,

   Jiten
>
>Please use similar formats.
>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
>
