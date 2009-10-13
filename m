From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] ax25: unsigned cannot be less than 0 in ax25_ctl_ioctl()
Date: Tue, 13 Oct 2009 11:48:38 +0200
Message-ID: <4AD44CF6.1070801@bfs.de>
References: <4AD0FB0B.8050609@gmail.com> <4AD34D3C.1060206@bfs.de> <4AD37D44.9050207@gmail.com> <4AD3A67B.6070703@cerebellum.kd>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Roel Kluin <roel.kluin@gmail.com>, linux-hams@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Joerg Reuter <jreuter@yaina.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Kevin Dawson <kevind@esi.com.au>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4AD3A67B.6070703@cerebellum.kd>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Kevin Dawson schrieb:
> Roel Kluin wrote:
> 
>>>  tmp_arg=ax25_ctl.arg * HZ;
>>>
>>>   if (arg == 0 || arg >  ULONG_MAX )
>>>         goto einval_put;
>>
>> I'm not sure, I think this would only work if we made `arg' an
>> unsigned long long.
> 
> That depends on the possible values of ax25_ctl.arg.
> 
>> +    if (ax25_ctl.arg * HZ > ULONG_MAX && ax25_ctl.cmd != AX25_KILL)
>> +        return -EINVAL;
> 
> Why the need to change arg before comparing it with a constant?  Let the
> compiler do the work:
> 
>     if (ax25_ctl.arg > ULONG_MAX / HZ && ...
> 
> Kevin
> 

i like this because it prevents a wrap around for stupid ax25_ctl.arg values but will not help when
ax25_ctl.arg * HZ is used later. NTL i think HZ does not need to be constant these days but i am not an
expert on that area.

  re,
   wh


