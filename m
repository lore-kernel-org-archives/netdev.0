From: David Ranch <linux-hams@trinnet.net>
Subject: Re: [PATCH v3 0/2] refactor code and mark expected switch
 fall-throughs
Date: Sat, 28 Oct 2017 10:53:24 -0700
Message-ID: <e5c376f0-fdd0-78a7-a40f-0b990cff0023@trinnet.net>
References: <cover.1509080630.git.garsilva@embeddedor.com>
 <b0e6de21-b258-dc78-4710-a61b81ec419c@trinnet.net>
 <20171027144853.Horde.ExzHfROE4gaCiHalihXFClP@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>,
        walter harms <wharms@bfs.de>, Kevin Dawson <hal@kd.net.au>,
        "Bernard, f6bvp" <f6bvp@free.fr>,
        Thomas Osterried <thomas@osterried.de>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20171027144853.Horde.ExzHfROE4gaCiHalihXFClP@gator4166.hostgator.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello Gustavo,

Thanks for the reply.  I do appreciate the work but we've had other 
people contribute to keep things up to date but previous minor patches 
broke parts of the AX.25 stack in strange ways.  The fixes weren't hard 
to repair or backout but due to the timing, various Linux distros based 
their releases on the broken kernel code and it's taken a LONG time to
get things healthy for them.  We need be able provide a test harness to 
developers to unit test / regression test their proposed code ideally 
AHEAD of the commit but at least after the commit.

I'm still failing to find any Linux groups that offer some sort of 
automated build & test environment (Travis, Jenkins, etc) tracking 
various kernel branches, etc.  It's gotta be out there (many of them in 
fact) but I'm struggling to find them.

For example, here is an excellent article about what *Intel* is doing 
for their graphics drivers but I need something that the general 
community can leverage for say various protocol stacks (TCP/IP, AX.25, 
whatever):

    https://lwn.net/Articles/735468/

 From that article, it seems that maybe this could be a good place to start:

    https://01.org/lkp
    https://github.com/intel/lkp-tests

Looks like a good start but is that what the majority of the Linux 
kernel folk use today?  Is it the right group for non-scaled out unit 
testing that I seek?  I also think this email-centric approach might be 
an overly broad approach with WAY too much noise for various development 
areas.

Does anyone else have thoughts on this topic?

--David
KI6ZHD


On 10/27/2017 12:48 PM, Gustavo A. R. Silva wrote:
> Hi David,
>
> Quoting David Ranch <linux-hams@trinnet.net>:
>
>> Hello Gustavo,
>>
>> I appreciate you working on keeping up the kernel and maintaining some
>> of the older feature areas like AX.25, Netrom, etc.  Other than
>> auditing your code changes, can you tell me what you're changing? I've
>> been attempting to find who / where does regression tests for the
>> Linus kernel to potentially ADD test suites for this area.  In the
>> recent past, we have seen a lot of toxicity creep into the kernel
>> because no one is testing their changes and backing out this toxic
>> code out of released Linux distributions takes a VERY long time.
>>
>
> Here you can see the patch I'm proposing to refactor some code:
> https://patchwork.kernel.org/patch/10029119/
>
> It does not add any new functionality. It's just a small function that
> helps to modularize and reduce the size of the code in the nr_add_node()
> function.
>
> The function I'm proposing (re_sort_routes) re-sort the routes in
> quality order. It takes as arguments a pointer to the nr_node structure
> which contains the routes within and the indexes of the routes to re-sort.
>
> This function also replaces a "manual" swap of the routes with a call to
> the swap macro.
>
> Thanks
> --
> Gustavo A. R. Silva
>
>> I'm willing to try and help here but I really would like to follow
>> some team's guidelines of how they would like tests to be created,
>> supported, etc.  Be it in VMs, containers, specific automation
>> languages, etc.
>>
>> --David
>> KI6ZHD
>>
>>
>>
>>
>> On 10/26/2017 10:50 PM, Gustavo A. R. Silva wrote:
>>> The aim of this patchset is firstly to refactor code in nr_route.c in
>>> order to make it
>>> easier to read and maintain and, secondly, to mark some expected
>>> switch fall-throughs
>>> in preparation to enabling -Wimplicit-fallthrough.
>>>
>>> I have to mention that I did not implement any unit test.
>>> If someone has any suggestions on how I could test this piece of code
>>> it'd be greatly appreciated.
>>>
>>> Thanks
>>>
>>> Changes in v2:
>>>  - Make use of the swap macro and remove inline keyword as suggested by
>>>    Walter Harms and Kevin Dawson.
>>>
>>> Changes in v3:
>>>  - Update subject for both patches.
>>>  - Add this cover letter as suggested by David Miller.
>>>
>>> Gustavo A. R. Silva (2):
>>>   net: netrom: nr_route: refactor code in nr_add_node
>>>   net: netrom: nr_route: mark expected switch fall-throughs
>>>
>>>  net/netrom/nr_route.c | 62
>>> ++++++++++++++++-----------------------------------
>>>  1 file changed, 19 insertions(+), 43 deletions(-)
>>>
>
>
>
>
>
