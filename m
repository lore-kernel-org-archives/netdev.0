From: Junling Zheng <zhengjunling@huawei.com>
Subject: Re: [RFC] [PATCH] net: socket: Fix the wrong returns for recvmsg
 and sendmsg
Date: Tue, 2 Jun 2015 14:19:46 +0800
Message-ID: <556D4B02.2070307@huawei.com>
References: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com> <20150602012154.GB23370@kroah.com> <556D2B8C.9010108@huawei.com> <20150602044449.GA19083@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <lizefan@huawei.com>, <viro@zeniv.linux.org.uk>,
	<davem@davemloft.net>, <xuhanbing@huawei.com>,
	<stable@vger.kernel.org>, <netdev@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150602044449.GA19083@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/6/2 12:44, Greg KH wrote:
> On Tue, Jun 02, 2015 at 12:05:32PM +0800, Junling Zheng wrote:
>> On 2015/6/2 9:21, Greg KH wrote:
>>> On Mon, Jun 01, 2015 at 09:28:00AM +0000, Junling Zheng wrote:
>>>> Hi, Greg:
>>>>
>>>> We found that after v3.10.73, recvmsg might return -EFAULT while -EINVAL
>>>> was expected.
>>>
>>> That means I messed up and applied something I shouldn't have, right?
>>>
>>> Can you use 'git bisect' to find the problem patch?  That's probably
>>> easier here, and then I can either revert it, or fix up a broken
>>> backport.
>>>
>>
>> So, the problem commit is 281c9c36 (net: compat: Update get_compat_msghdr() to match copy_msghdr_from_user() behaviour), which fixes db31c55a6fb2
>> and brings the get_compat_msghdr() in line with copy_msghdr_from_user().
> 
> Ok, but that patch itself isn't the issue, as it's "correct".  Something

I don't think so. The commit 281c9c36 is indeed the issue. Its upstream commit 91edd09
has no problem in mainline, however it's not appropriate or complete for 3.10-stable.
It changes the return value of get_compat_msghdr(), however, the outer caller still
returns -EFAULT unconditionally, which goes against the intention of author.

So, I don't think 281c9c36 is an complete patch for 3.10-stable. We should also fix it
to return a correct value according to get_compat_msghdr() rather than returning -EFAULT
unconditionally :)

Cheers,

Junling

> else must be wrong here, did we backport db31c55a6fb2 incorrectly to
> 3.10-stable?  What is really causing this to be so different that your
> proposed patch needs to be applied to solve it?
> 
> thanks,
> 
> greg k-h
> 
> .
> 
