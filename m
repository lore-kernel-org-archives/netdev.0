From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v4 0/3] net: reserve ports for applications using
 fixed port
Date: Wed, 17 Feb 2010 23:57:08 +0800
Message-ID: <4B7C11D4.1080309@redhat.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <201002162151.04861.opurdila@ixiacom.com> <m1mxz93pw2.fsf@fess.ebiederm.org> <201002162322.13101.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002162322.13101.opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Octavian Purdila wrote:
> On Tuesday 16 February 2010 22:08:13 you wrote:
>>> Something like bellow?
>>>
>>> # set bits 8080 and 1666
>>> $echo 8080 1666-1666 > /proc
>>>
>>> #reset bit 1666
>>> $echo 8080 > /proc
>>>
>>> #reset whole bitmap
>>> $echo > /proc
>> Yes. So something like that.
>>
>> I think I would use commas instead of spaces as that is more traditional.


Why this is better than the current version?

For the single port case, currently we use:

echo +8080 > /xxxx #set
echo -8080 > /xxxx #clear

Now we will use:

echo 8080 > /xxxx #set
echo 8080 > /xxxx #clear

I don't think the latter is better...

For the multi-port case, yes, we should accept 'echo 8080,10000 >/xxxx'.


>>
> 
> OK, I was trying to reuse the existing skip whitespace code :) but if you 
> think its cleaner with commas I can do that.
> 
>>> Note that this new proc entry will work in conjunction with the existing
>>> ip_local_port_range option, so the default bitmap can (and should be)
>>> empty.

Yes, we don't know which ports the user wants to reserve.


>> Do we want userspace to see this implementation detail? Two data structures
>>  doing the almost the same thing could get confusing in a hurry.  It feels
>>  like a recipe for changing one and not the other and then running around
>>  trying to figure out why the change did not work.
>>
> 
> Yes, I believe we want to have reserved_ports contain just those special ports 
> that the user wants to reserve. After all we add this entry for this specific 
> purpose. 
> 

This is why I insist we should make sure all ports accepted by
ip_local_reserved_ports must be in ip_local_port_range.
