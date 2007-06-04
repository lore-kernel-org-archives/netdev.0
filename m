From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] Fix bug of update IPv4 PMTU when received ICMP Fragmentation
 Needed message
Date: Mon, 04 Jun 2007 12:03:57 +0800
Message-ID: <46638F2D.90608@cn.fujitsu.com>
References: <E1HuRAd-0002Wl-00@gondolin.me.apana.org.au> <46635F39.2090009@cn.fujitsu.com> <20070604025528.GA27750@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:62193 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751357AbXFDEKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 00:10:10 -0400
In-Reply-To: <20070604025528.GA27750@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Mon, Jun 04, 2007 at 08:39:21AM +0800, Wei Yongjun wrote:
>   
>>> Huh? The test new_mtu >= old_mtu should only hold if the sending router
>>> is buggy which is what the hack is for.
>>>       
>> Note here old_mtu is not the real old mtu, is the received message's size:
>>  unsigned short old_mtu = ntohs(iph->tot_len);
>> So maybe the patch would like following.
>>     
>
> The size of the packet that caused the ICMP is what we want here.  That's
> why the router must be buggy.
>
>   
So I want to know how the route announce a MTU larger then 576, such as 
1280? RFC says ICMP error message return as much as we can without 
exceeding 576 bytes.
And ipv4 router alaways return as a packet size 576 because of this.
If MTU is greater then 576, HOST will used "mtu = guess_mtu(old_mtu)" to 
get a MTU. Method of send ICMP Fragmentation Needed message is 
difference from receive,
how can this resolve? Change the method of send ICMP Fragmentation 
Needed message? I do not think so, the  only think we  can  do is  to 
change  the method of receive ICMP message.
Do you agree this?

-- 

A new email address of FJWAN is launched from Apr.1 2007.
The updated address is: yjwei@cn.fujitsu.com 
--------------------------------------------------
Wei Yongjun
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630523-858
COINS: 79955-858
FAX: +86+25-83317685
MAIL: yjwei@cn.fujitsu.com
--------------------------------------------------

