From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Problem with talking to the kernel and iproute2/ifconfig
Date: Thu, 25 Mar 2010 18:52:09 +0100
Message-ID: <4BABA2C9.3090805@itcare.pl>
References: <4BAB88A3.9070702@itcare.pl> <4BAB9E02.2040605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:60813 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109Ab0CYRwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Mar 2010 13:52:14 -0400
In-Reply-To: <4BAB9E02.2040605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes
This patch resolve this problem and all is working now correctly.

cat gateways.conf | grep 'addr add' | wc -l
6267
ip -batch gateways.conf
ip a sh | grep ' 10.' | grep inet | wc -l
6267




W dniu 2010-03-25 18:31, Patrick McHardy pisze:
> Pawe=C5=82 Staszewski wrote:
>   =20
>> Hello
>>
>> I have strange problem with kernel 2.6.33.1
>>
>> I have script with 6267 ip's
>>
>> cat gateways.conf | grep 'addr add' | wc -l
>> 6267
>>
>> and when i want to commit this interfaces by command:
>> ip -batch gateways.conf
>>
>> I have only 680 ip interfaces
>> ip a | grep inet | grep ' 10.' | wc -l
>> 680
>>
>>
>> I test this on kernels 2.6.29.1 and 2.6.30.1 and all was OK.
>> on kernel 2.6.29.1
>>
>> ip -batch gateways.conf
>> ip a | grep inet | grep ' 10.' | wc -l
>> 6267
>>
>> on kernel 2.6.30.1
>> ip -batch gateways.conf
>> ip a | grep inet | grep ' 10.' | wc -l
>> 6267
>>     =20
> Does this patch help? When "idx" points to the last device
> of a chain, it will never get incremented past s_idx and we
> fail to reset s_ip_idx.
>
>   =20

