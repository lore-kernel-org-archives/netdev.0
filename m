From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Tue, 17 Jun 2003 14:31:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEF88C8.30005@us.ibm.com>
References: <20030531.110249.12960077.yoshfuji@linux-ipv6.org>	<20030530.233257.21920899.davem@redhat.com>	<3EEF7E09.8080608@us.ibm.com> <20030618.055959.55006678.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030618.055959.55006678.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Yoshifuji,

 > Well, I think the problem is to set RTF_ADDRCONF flag to all prefix routes.

I don't think we should change that, RTF_ADDRCONF should be set for all RA
routes not just the prefix route. But I agree with your other comments,
that RTF_ADDRCONF must not be used when configuring routes from user space.
The filtering should check for both the flag as well as whether it is a
prefix route entry.

I guess I will work on sending messages for both prefix list changes and to
get entire prefix list.

thanks,

- KK

YOSHIFUJI Hideaki wrote:
> In article <3EEF7E09.8080608@us.ibm.com> (at Tue, 17 Jun 2003 13:46:01 -0700), Krishna Kumar <krkumar@us.ibm.com> says:
> 
> 
>>I have a question about the following, which seems to be the
>>approach both of you prefer. I thought we need a new routing
>>message type called RTM_GETPLIST which will return full prefix
>>list. If you use RTA_RA6INFO, then should that trigger only
>>when the prefix list has changed (add or delete) ? Should I
>>have both interfaces, one for returning entire list (RTM) and
>>one for changes in prefix list (RTA) ?
>>
>>Please let me know if my understanding is correct.
> 
> 
> Well, I think the problem is to set RTF_ADDRCONF flag to all prefix routes.
> I beleive this should be for autoconf (RA) routes only as comments says;
> dad_starts and multicast add routes with such flag, but this should be wrong.
> After we fix this, we can get prefix information filtering routes by 
> RTF_ADDRCONF flag; of course, we can get the routes using RTM_GETROUTE.
> 
