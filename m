From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH v3 2/2] decrement static keys on real destroy time
Date: Thu, 26 Apr 2012 19:28:39 -0300
Message-ID: <4F99CC17.4080006@parallels.com>
References: <1335475463-25167-1-git-send-email-glommer@parallels.com> <1335475463-25167-3-git-send-email-glommer@parallels.com> <20120426213916.GD27486@google.com> <4F99C50D.6070503@parallels.com> <20120426221324.GE27486@google.com> <4F99C980.3030801@parallels.com> <CAOS58YOKUq7GTTZRcw19dth+HgThoNTEcqBKeNO0ftB4rFJ97A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <cgroups@vger.kernel.org>, <netdev@vger.kernel.org>, Li Zefan
	<lizefan@huawei.com>, <kamezawa.hiroyu@jp.fujitsu.com>, <linux-mm@kvack.org>,
	<devel@openvz.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAOS58YOKUq7GTTZRcw19dth+HgThoNTEcqBKeNO0ftB4rFJ97A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 04/26/2012 07:22 PM, Tejun Heo wrote:
> Hello,
>
> On Thu, Apr 26, 2012 at 3:17 PM, Glauber Costa<glommer@parallels.com>  wrote:
>>
>>> No, what I mean is that why can't you do about the same mutexed
>>> activated inside static_key API function instead of requiring every
>>> user to worry about the function returning asynchronously.
>>> ie. synchronize inside static_key API instead of in the callers.
>>>
>>
>> Like this?
>
> Yeah, something like that.  If keeping the inc operation a single
> atomic op is important for performance or whatever reasons, you can
> play some trick with large negative bias value while activation is
> going on and use atomic_add_return() to determine both whether it's
> the first incrementer and someone else is in the process of
> activating.
>
> Thanks.
>
We need a broader audience for this, but if I understand the interface 
right, those functions should not be called in fast paths at all 
(contrary to the static_branch tests)

The static_branch tests can be called from irq context, so we can't just 
get rid of the atomic op and use the mutex everywhere, we'd have
to live with both.

I will repost this series, with some more people in the CC list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
