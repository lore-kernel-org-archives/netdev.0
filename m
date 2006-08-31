From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: high latency with TCP connections
Date: Thu, 31 Aug 2006 08:44:57 -0700
Message-ID: <44F703F9.6050907@us.ibm.com>
References: <20060830100734.GA22235@isil.ipib.msu.ru> <20060830102727.11e11453@localhost.localdomain> <20060830.143955.55510936.davem@davemloft.net> <20060831081443.GA27075@isil.ipib.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:22155 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751653AbWHaPpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 11:45:14 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7VFj9IR009542
	for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 11:45:09 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7VFj9Tb230452
	for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 11:45:09 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7VFj8Sh020085
	for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 11:45:09 -0400
To: Alexander Vodomerov <alex@sectorb.msk.ru>
In-Reply-To: <20060831081443.GA27075@isil.ipib.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexander Vodomerov wrote:
> On Wed, Aug 30, 2006 at 02:39:55PM -0700, David Miller wrote:
>   
>>> Expecting any performance with one byte write's is silly.
>>>       
>> This is absolutely true.  TCP_NODELAY can only save you when you are
>> sending a small amount of data "in aggregate", such as in an SSH or
>> telnet session, whereas in the case being shown here a large amount of
>> data is being sent in small chunks which will always get bad
>> performance.
>>     
>
> Information is sent with one byte write's because it is not available at
> the moment of sending (it may be read from hardware device or user). If
> I change 1 to 10 or 100 nothing changes. I'm afraid there is a bit of
> misunderstanding here. Only very small amount of data is being sent over
> network. The total traffic for example I sent is only 10 bytes/s. After
> every 10th packet program does usleep(100000) to simulate pause before
> next available data.
>
> There are really 3 factors:
> 1) total size of information is small
> 2) data for transferring is arrived by small portions from external
> source
> 3) it is very important that any portion should be delivered to receiver
> as soon as possible.
> Is TCP is good choice for such transfer or some other protocol is better
> suited?
>   
If message boundary preservation is a useful feature for your app, you 
could try SCTP.
You should be able to do this by replacing IPPROTO_TCP with IPPROTO_SCTP and
TCP_NODELAY with SCTP_NODELAY.

Thanks
Sridhar
> With best regards,
>    Alexander.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


