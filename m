From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Tue, 18 Aug 2009 19:47:57 +0300
Message-ID: <4A8ADB3D.2080606@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8ACE1F.6020402@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 06:51 PM, Gregory Haskins wrote:
>
>> It's not laughably trivial when you try to support the full feature set
>> of kvm (for example, live migration will require dirty memory tracking,
>> and exporting all state stored in the kernel to userspace).
>>      
> Doesn't vhost suffer from the same issue?  If not, could I also apply
> the same technique to support live-migration in vbus?
>    

It does.  There are two possible solutions to that: dropping the entire 
protocol to userspace, or the one I prefer, proxying the ring and 
eventfds in userspace but otherwise letting vhost-net run normally.  
This way userspace gets to see descriptors and mark the pages as dirty.  
Both these approaches rely on vhost-net being an accelerator to a 
userspace based component, but maybe you can adapt venet to use 
something similar.

>> Oh come on, I wrote "steal" as a convenient shorthand for
>> "cross-pollinate your ideas into our code according to the letter and
>> spirit of the GNU General Public License".
>>      
> Is that supposed to make me feel better about working with you?  I mean,
> writing, testing, polishing patches for LKML-type submission is time
> consuming.  If all you are going to do is take those ideas and rewrite
> it yourself, why should I go through that effort?
>    

If you're posting your ideas for everyone to read in the form of code, 
why not post them in the form of design ideas as well?  In any case 
you've given up any secrets.  In the worst case you've lost nothing, in 
the best case you may get some hopefully constructive criticism and 
maybe improvements.

I'm perfectly happy picking up ideas from competing projects (and I 
have) and seeing my ideas picked up in competing projects (which I also 
have).

Really, isn't that the point of open source?  Share code, but also share 
ideas?

> And its not like that was the first time you have said that to me.
>    

And I meant it every time.

Haven't you just asked how vhost-net plans to do live migration?

>> Since we're all trying to improve Linux we may as well cooperate.
>>      
> Well, I don't think anyone can say that I haven't been trying.
>    

I'd be obliged if you reveal some of your secret sauce then (only the 
parts you plan to GPL anyway of course).

>>> "sorry, we are going to reinvent our own instead".
>>>        
>> No.  Adopting venet/vbus would mean reinventing something that already
>> existed.
>>      
> But yet, it doesn't.
>    

We'll need to do the agree to disagree thing again here.

>>   Continuing to support virtio/pci is not reinventing anything.
>>      
> No one asked you to do otherwise.
>    

Right, and I'm not keen on supporting both.  See why I want to stick to 
virtio/pci as long as I possibly can?

>> You haven't convinced me that your ideas are worth the effort of
>> abandoning virtio/pci or maintaining both venet/vbus and virtio/pci.
>>      
> With all due respect, I didnt ask you do to anything, especially not
> abandon something you are happy with.
>
> All I did was push guest drivers to LKML.  The code in question is
> independent of KVM, and its proven to improve the experience of using
> Linux as a platform.  There are people interested in using them (by
> virtue of the number of people that have signed up for the AlacrityVM
> list, and have mailed me privately about this work).
>
> So where is the problem here?
>    

I'm unhappy with the duplication of effort and potential fragmentation 
of the developer and user communities, that's all.  I'd rather see the 
work going into vbus/venet going into virtio.  I think it's a legitimate 
concern.

-- 
error compiling committee.c: too many arguments to function

