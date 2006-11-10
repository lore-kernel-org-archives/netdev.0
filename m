From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] IPv6: only modify checksum for UDP
Date: Fri, 10 Nov 2006 15:17:06 -0800
Message-ID: <45550872.6050900@us.ibm.com>
References: <45536622.90708@hp.com>	<20061109.151402.15590179.davem@davemloft.net>	<4554A7CD.6040907@hp.com> <20061110.145507.112290147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, viro@ftp.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:50125 "EHLO e6.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1424454AbWKJXRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 18:17:15 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAANHXaM017966
	for <netdev@vger.kernel.org>; Fri, 10 Nov 2006 18:17:33 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAANHDae232768
	for <netdev@vger.kernel.org>; Fri, 10 Nov 2006 18:17:13 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAANHD11012199
	for <netdev@vger.kernel.org>; Fri, 10 Nov 2006 18:17:13 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061110.145507.112290147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Brian Haley <brian.haley@hp.com>
> Date: Fri, 10 Nov 2006 11:24:45 -0500
> 
>> Only change upper-layer checksum from 0 to 0xFFFF for UDP (as RFC 768 
>> states), not for others as RFC 4443 doesn't require it.
>>
>> Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> Applied, thanks Brian.


Brian Haley wrote:
 > Al Viro wrote:
 >> Could you fscking read what you've replied to?  Your -=1 will turn 0
 >> into 0xffff instead of correct 0xfffe.  IOW, it's broken in 1:65536
 >> cases.
 >
 > I looked again at your previous email:
 >
 >> Note that even on little-endian you want
 >>     3 -> 2
 >>     2 -> 1
 >>     1 -> 0xffff
 >>     0 -> 0xfffe
 >
 > That doesn't look right to me, but I'll take your word that there's one
 > edge case out there I don't see (even though this worked on Alpha).
 > Forget about the patch then.

Er, given all of the above, Brian, could you share your test cases
and/or other/any information on testing this?

thanks,
Nivedita
