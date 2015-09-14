From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] atm: deal with setting entry before mkip was called
Date: Mon, 14 Sep 2015 13:00:26 -0400
Message-ID: <55F6FD2A.7080004@oracle.com>
References: <1442245730-31575-1-git-send-email-sasha.levin@oracle.com> <1442249450.14284.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22096 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754436AbbINRAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 13:00:40 -0400
In-Reply-To: <1442249450.14284.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2015 12:50 PM, Eric Dumazet wrote:
> On Mon, 2015-09-14 at 11:48 -0400, Sasha Levin wrote:
> 
>>
>> diff --git a/net/atm/clip.c b/net/atm/clip.c
>> index 17e55df..4407b2f 100644
>> --- a/net/atm/clip.c
>> +++ b/net/atm/clip.c
>> @@ -317,6 +317,9 @@ static int clip_constructor(struct neighbour *neigh)
>>  
>>  static int clip_encap(struct atm_vcc *vcc, int mode)
>>  {
>> +	if (!CLIP_VCC(vcc))
>> +		return -EBADF;
>> +
>>  	CLIP_VCC(vcc)->encap = mode;
>>  	return 0;
>>  }
> 
> 
> -EBADF has a very precise meaning : /* Bad file number */
> 
> In this case, the file number is correct (and maps to a proper file),
> but driver state is not allowing for this particular operation.

I've tried to be consistent with a similar check within clip_mkip() and
clip_setentry():

        if (!vcc->push)
                return -EBADFD;

So calling clip_setentry() before clip_mkip() would also give you -EBADFD.


Thanks,
Sasha
