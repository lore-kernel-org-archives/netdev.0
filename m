From: Eduardo Otubo <otubo@redhat.com>
Subject: Re: [PATCH] hv_set_ifconfig.sh double check before setting ip
Date: Thu, 10 Aug 2017 09:40:27 +0200
Message-ID: <0b0a89e2-250e-69d9-9b24-1cf49e9c1d26@redhat.com>
References: <20170808135345.17027-1-otubo@redhat.com>
 <20170808.211150.2070475124549651350.davem@davemloft.net>
 <494db0c8-8c31-f2ce-17fc-7b96b74f0b28@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@linuxdriverproject.org, sthemmin@microsoft.com,
        haiyangz@microsoft.com, kys@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <494db0c8-8c31-f2ce-17fc-7b96b74f0b28@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/09/2017 11:02 AM, Eduardo Otubo wrote:
> On 08/09/2017 06:11 AM, David Miller wrote:
>> From: Eduardo Otubo <otubo@redhat.com>
>> Date: Tue,  8 Aug 2017 15:53:45 +0200
>>
>>> This patch fixes the behavior of the hv_set_ifconfig script when setting
>>> the interface ip. Sometimes the interface has already been configured by
>>> network daemon, in this case hv_set_ifconfig causes "RTNETLINK: file
>>> exists error"; in order to avoid this error this patch makes sure double
>>> checks the interface before trying anything.
>>>
>>> Signed-off-by: Eduardo Otubo <otubo@redhat.com>
>>
>> And if the daemon sets the address after you test it but before
>> you try to set it in the script, what happens?
>>
>> This is why I hate changes like this.  They don't remove the problem,
>> they make it smaller.  And smaller in a bad way.  Smaller makes the
>> problem even more harder to diagnose when it happens.
>>
>> There is implicitly no synchonization between network configuration
>> daemons and things people run by hand like this script.
>>
>> So, caveat emptor.
>>
>> I'm not applying this, sorry.

But also, looking from a different point of view, the current upstream 
solution does not avoid the problems you mentioned. My fix at least 
avoids double configuration and RTNETLINK errors. So perhaps you could 
consider this as "a better version walking towards an ideal fix"?

>>
> 
> This is just part of the resolution, actually. For RHEL I also configure 
> hyperv-daemons' systemd config file to be run only after network service 
> is up.
> 
> So perhaps my solution should be distro-agnostic and only involve this 
> script as part of it? In this case I'll elaborate a little more then.
> 
> Thanks for the comment.
