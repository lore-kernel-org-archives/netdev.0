From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH 1/4] Prefix List against 2.5.73
Date: Tue, 15 Jul 2003 17:11:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F149847.2000408@us.ibm.com>
References: <200307150117.FAA06705@dub.inr.ac.ru> <3F14492C.30708@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, davem@redhat.com,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <3F14492C.30708@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 > I proposechanging the values of IFA_PERM/TENT/DEPRE/SECOND, etc,

On the other hand, to maintain compatibility with existing apps (ip command),
I can change the new values instead. So now the same ip util program will
display the correct flag values for the address and then display the remaining
flags which are the O/M flags.

I will send patch for this tomorrow.

Thanks,

- KK

> Hi Alexey,
> 
>>> +    IFA_IFFLAGS,
>>
>>
>> What's about ifa_flags? There is some space there, and the things
>> kept there now: TENTATIVE/DEPRECATED et al. are close relatives
>> of O/M.
> 
> 
>  > > Alexey, O/M are not flags for addresses, but for interfaces.
> 
>  > > > But tell me, please, what is the difference between new _address_
>  > > > attribute IFA_IFFLAGS and already existing address attrbute 
> ifa_flags?
> 
> Conceptually these are different, one for address and one for interface. 
> But I also
> agree to your point that these can both be enclosed within one attribute 
> to return.
> If we agree to do it in this way, then we have to change the values of 
> either of
> the two sets of #defines (if_flags & ifa_flags since they intersect). I 
> propose
> changing the values of IFA_PERM/TENT/DEPRE/SECOND, etc, for no other 
> reason other
> than the MANAGED/OTHER flags has values copied off from the RA (bitwise 
> values of
> the icmpv6_nd_ra field of RA). It might make more meaning to keep 0x80 
> for field 'M'
> which is the first bit of the field, but let me know if this is not 
> acceptable.
> 
>> This does not pass through Occam's razor. Why not to give a filter to 
>> plain
>> RTM_GETROUTE? We did not implement filtering not because we do not want,
>> but because we (me, is more appropriate) are lazy.
> 
> 
> OK, I can change that to give a filter. Is it OK to add the filter to 
> rtm_flags ?
> I was thinking of adding RTM_F_PREFIX, and rt6_dump_route() can pass 
> this information
> to rt6_fill_node() which does filtering of routes based on whether this 
> flag is set
> or not. Did I understand you correctly here ?
> 
>> Also, I am not sure that the interface should include things sort of
>>
>> +    if ((addr_type & (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK |
>> +            IPV6_ADDR_MULTICAST)) != 0 ||
>> +            addr_type == IPV6_ADDR_ANY)
>>
> 
> I can remove the check completely and introduce a new flag RTF_PREFIX_RT 
> to distinguish
> between various route types.
> 
> Are these modifications OK ?
> 
> Thanks,
> 
> - KK
> 
>> For kernel all they are direct routes, if the application wants to apply
>> some policy not formulated in terms of filters for RTM_GETROUTE, let it
>> to filter itself. Moreover, I used to emphasize that user of rtnetlink
>> should not believe to reliability of kernel filtering. It is just 
>> necessary
>> measure to guarantee that a new application, which is aware of a new
>> attribute, will behave correctly with older kernels, which are not aware
>> of this attribute. Not a requirement, of course.
>>
>> Anyway, if you want to apply such specific policy, you can add a flag
>> to rtm_flags, which would say: RTM_F_OFFICIALLY_PREFIX and base filtering
>> on this flag, when it is given.
>>
>> Alexey
>>
> 
