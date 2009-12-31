From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Thu, 31 Dec 2009 13:09:14 -0500
Message-ID: <4B3CE8CA.5050003@majjas.com>
References: <4B300A2A.8040305@gmail.com> <4B300E30.9090707@majjas.com>
 <4B3114E3.1070602@majjas.com> <4B329FA3.9090904@majjas.com>
 <20091223230102.4bb0100e.akpm@linux-foundation.org>
 <4B34E847.8010809@majjas.com> <20091225152200.1cf11dfe@nehalam>
 <4B3581C7.8000702@majjas.com> <20091226095723.7ac82b18@nehalam>
 <4B367409.5060202@majjas.com> <4B379378.4000102@majjas.com>
 <20091227102238.0df149f9@nehalam> <4B37B7E2.5070307@majjas.com>
 <20091229093023.3ad24786@nehalam> <4B3A5048.9090700@majjas.com>
 <20091229114938.1f4d1c5c@nehalam> <4B3AFFE8.3060409@majjas.com>
 <20091229235942.51bf733d@nehalam> <4B3B7488.6080503@majjas.com>
 <20091230101046.2816d545@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta5.srv.hcvlny.cv.net ([167.206.4.200]:59509 "EHLO
	mta5.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbZLaSJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 13:09:44 -0500
In-reply-to: <20091230101046.2816d545@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Did some more digging today... Haven't nailed it, but there's something 
going on with X and tty...

Among other things, when I telinit 3 && telinit 5 the tty keeps 
switching between 7 and 8 (nothing else running on either tty). It would 
appear that somehow the tty deallocation isn't complete when X restarts. 
Also, X grabbing a tty seems to be a requisite step in recreating the 
sky2 issue.

On 12/30/2009 1:10 PM, Stephen Hemminger wrote:
> On Wed, 30 Dec 2009 10:40:56 -0500
> Michael Breuer<mbreuer@majjas.com>  wrote:
>
>    
>> Dec 30 10:37:14 mail kernel: sky2 0000:06:00.0: error interrupt
>> status=0x40000008
>> Dec 30 10:37:14 mail kernel: sky2 Tx ring pending=31...40 report=35 done=35
>> Dec 30 10:37:14 mail kernel: 30: 0x0: 0xeb50c0ca(9014)
>> Dec 30 10:37:14 mail kernel: 32: 0x0: 0xeb5080ca(9014)
>> Dec 30 10:37:14 mail kernel: 34: 0x0: 0xeb5040ca(9014)
>> Dec 30 10:37:14 mail kernel: 36: 0x0: 0xeb5000ca(9014)
>> Dec 30 10:37:14 mail kernel: 38: 0x0: 0xeb4fc0ca(9014)
>>      
> You must be using 9K MTU.  Do you see the problem with smaller
> MTU?
>
>    
>> Dec 30 10:37:14 mail kernel: sky2 0000:06:00.0: error interrupt
>> status=0x40000008
>> Dec 30 10:37:14 mail kernel: sky2 Tx ring pending=87...92 report=89 done=91
>> Dec 30 10:37:14 mail kernel: 86: 0x0: 0xeafd80ca(9014)
>> Dec 30 10:37:14 mail kernel: 88: 0x0: 0xeafd40ca(9014)
>> Dec 30 10:37:14 mail kernel: 90: 0x0: 0xeafd00ca(9014)
>> Dec 30 10:37:15 mail kernel: sky2 0000:06:00.0: error interrupt status=0x8
>> Dec 30 10:37:15 mail kernel: sky2 Tx ring pending=39...42 report=39 done=41
>> Dec 30 10:37:15 mail kernel: 38: 0x0: 0xe5fec0ca(9014)
>> Dec 30 10:37:15 mail kernel: 40: 0x0: 0xe5fe80ca(9014)
>> Dec 30 10:37:15 mail kernel: sky2 0000:06:00.0: error interrupt
>> status=0x40000008
>> Dec 30 10:37:15 mail kernel: sky2 Tx ring pending=117...124 report=119
>> done=119
>> Dec 30 10:37:15 mail kernel: 116: 0x0: 0xe5d6c0ca(9014)
>> Dec 30 10:37:15 mail kernel: 118: 0x0: 0xe5d680ca(9014)
>> Dec 30 10:37:15 mail kernel: 120: 0x0: 0xe5d660ca(5938)
>> Dec 30 10:37:15 mail kernel: 122: 0x0: 0xe5d640ca(4213)
>>      
>    

