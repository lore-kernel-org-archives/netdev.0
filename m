From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v7 9/9] xen-netback: Aggregate TX unmap operations
Date: Thu, 20 Mar 2014 16:11:12 +0000
Message-ID: <532B1320.1070607@citrix.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com> <1394142511-14827-10-git-send-email-zoltan.kiss@citrix.com> <532A0915.5090006@citrix.com> <20140320104855.GA16285@zion.uk.xensource.com> <9AAE0902D5BC7E449B7C8E4E778ABCD0292550@AMSPEX01CL01.citrite.net> <20140320123839.GK16807@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jonathan Davies <Jonathan.Davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140320123839.GK16807@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/03/14 12:38, Wei Liu wrote:
> On Thu, Mar 20, 2014 at 11:14:51AM +0000, Paul Durrant wrote:
>>> -----Original Message-----
>>> From: Wei Liu [mailto:wei.liu2@citrix.com]
>>> Sent: 20 March 2014 10:49
>>> To: Zoltan Kiss
>>> Cc: Ian Campbell; Wei Liu; xen-devel@lists.xenproject.org;
>>> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jonathan Davies;
>>> Paul Durrant
>>> Subject: Re: [PATCH net-next v7 9/9] xen-netback: Aggregate TX unmap
>>> operations
>>>
>>> On Wed, Mar 19, 2014 at 09:16:05PM +0000, Zoltan Kiss wrote:
>>>> Hi,
>>>>
>>>> I'm thinking about revoking this patch: it's value is pretty small,
>>>> but it causes performance regression on Win7 guests. And probably it
>>>> is not the best solution for this problem. It might be the delay it
>>>> takes the dealloc thread to be scheduled is enough.
>>>> What do you think?
>>>>
>>>
>>> Can you elaborate? What makes Win7 so special? What's performance
>>> impact to other guests?
>>>
>>
>> It won't be Win7 specifically I expect. It will likely by any version
>> of Windows, or any other OS that limits the TXs-in-flight so
>> aggressively. Basically you need to TX-complete reasonably frequently
>> otherwise your throughput drops off a lot. IIRC at Solarflare we found
>> every ~500us to be just about frequent enough for hitting 10G.
>
> Thanks for the explanation.
>
> Reverting this change basically means when to flush TLB is at sole
> discretion of Linux kernel scheduler. I don't oppose to that. But it
> would be better to provide some numbers.

My comparisons with iperf haven't showed any significant difference. 
I've measured Win7 and upstream Linux guest.
There was a misunderstanding that reverting this patch would stop 
batching of unmap. There would be still batching as when the callback 
wakes the dealloc thread, by the time it happens other callbacks still 
can place work on the dealloc ring, even while the thread started to 
process them. And that could happen independently from the TX operations 
in the NAPI instance, which is an another good feature of having a 
dealloc thread.

I've discussed this in person with Paul and Ian as well, they are happy 
with the reverting. So David, can you please revert e9275f5e2d 
"xen-netback: Aggregate TX unmap operations"?

Regards,

Zoli
