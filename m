From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [flame^Wreview] net: netprio_cgroup: rework update socket logic
Date: Mon, 13 Aug 2012 10:31:22 -0700
Message-ID: <502939EA.80907@intel.com>
References: <20120813015348.GZ23464@ZenIV.linux.org.uk> <502896C5.7080303@intel.com> <50289D7F.3070402@intel.com> <20120813121827.GB23464@ZenIV.linux.org.uk> <50293224.90803@intel.com> <20120813170109.GD23464@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120813170109.GD23464@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/13/2012 10:01 AM, Al Viro wrote:
> On Mon, Aug 13, 2012 at 09:58:12AM -0700, John Fastabend wrote:
>> [...]
>>
>>> HOWEVER, it still doesn't address more fundamental problem - somebody
>>> creating a socket and passing it to you in SCM_RIGHTS datagram will
>>> leave you with a socket you can do IO on, still tagged according to who
>>> had created it.
>>>
>>> AFAICS, the whole point of that exercise was to allow third-party changing
>>> the priorities of traffic on sockets already created by a process we now
>>> move to a different cgroup.  Consider e.g. this:
>>
>> Correct that is the point of the exercise.
>>
>> To fix this specific case we could add a call to sock_update_netprioidx
>> in scm_recv to set the sk_cgrp_prioidx value.
>
> On every received descriptor, that is?  Eeek...
>

We are already iterating through the files in scm_detach_fds called from
scm_recv(). This would be an extra (file->f_op == &socket_file_ops)
check here and then the sock update.
