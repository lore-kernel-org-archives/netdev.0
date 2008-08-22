From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 1/4 2.6.28] cxgb3 - manage a private ip address for iSCSI
Date: Fri, 22 Aug 2008 15:09:12 -0500
Message-ID: <48AF1CE8.8020203@opengridcomputing.com>
References: <200808221838.m7MIcW6a004400@localhost.localdomain>	<20080822120851.c45a90f2.akpm@linux-foundation.org>	<48AF10BE.9050100@opengridcomputing.com> <20080822125316.37547cce.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	davem@davemloft.net, michaelc@cs.wisc.edu, rdreier@cisco.com,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	divy@chelsio.com, dm@chelsio.com, leedom@chelsio.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757454AbYHVUGp@vger.kernel.org>
In-Reply-To: <20080822125316.37547cce.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Fri, 22 Aug 2008 14:17:18 -0500
> Steve Wise <swise@opengridcomputing.com> wrote:
>
>   
>> Andrew Morton wrote:
>>     
>>>> +	unsigned long octet;
>>>> +	const char *parse = buf;
>>>> +	char *endp;
>>>> +	int i;
>>>> +
>>>> +	for (i = 1; i <= 4; i++) {
>>>> +		octet = simple_strtoul(parse, &endp, 10);
>>>> +		if (endp == buf || octet > 255 ||
>>>> +		    (i < 4 && *endp != '.') ||
>>>> +		    (i == 4 && *endp != '\0' && *endp != '\n'))
>>>> +			return -EINVAL;
>>>> +		a = (a << 8) | octet;
>>>> +		parse = endp+1;
>>>> +	}
>>>> +	pi->iscsi_ipaddr = htonl(a);
>>>> +	return endp-buf;
>>>> +}
>>>>     
>>>>         
>>> This appears to be taking a dotted quad ipv4 address in ascii form,
>>> turning it into a u32 while performing checking?
>>>
>>> Surely we have a library function somewhere in networking which does
>>> this?  If not, I'd suggest writing one. 
>>>
>>>   
>>>       
>> try in_aton() from include/linux/inet.h.
>>
>>     
>
> yeah.  But that function is a crock.  No error checking at all!
>   

Oh you want error checking?

:)

Yea if this is a user/sysadmin supplied value, then we need a rubust 
inet_aton() in the kernel to validate it...
