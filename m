From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Wed, 19 Aug 2009 08:22:25 +0300
Message-ID: <4A8B8C11.9030800@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818161434.GA15884@elte.hu> <4A8B7F17.6050100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751300AbZHSFW1@vger.kernel.org>
In-Reply-To: <4A8B7F17.6050100@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/19/2009 07:27 AM, Gregory Haskins wrote:
>
>> This thread started because i asked you about your technical
>> arguments why we'd want vbus instead of virtio.
>>      
> (You mean vbus vs pci, right?  virtio works fine, is untouched, and is
> out-of-scope here)
>    

I guess he meant venet vs virtio-net.  Without venet vbus is currently 
userless.

> Right, and I do believe I answered your questions.  Do you feel as
> though this was not a satisfactory response?
>    

Others and I have shown you its wrong.  There's no inherent performance 
problem in pci.  The vbus approach has inherent problems (the biggest of 
which is compatibility, the second managability).

>> Your answer above
>> now basically boils down to: "because I want it so, why dont you
>> leave me alone".
>>      
> Well, with all due respect, please do not put words in my mouth.  This
> is not what I am saying at all.
>
> What I *am* saying is:
>
> fact: this thread is about linux guest drivers to support vbus
>
> fact: these drivers do not touch kvm code.
>
> fact: these drivers to not force kvm to alter its operation in any way.
>
> fact: these drivers do not alter ABIs that KVM currently supports.
>
> Therefore, all this talk about "abandoning", "supporting", and
> "changing" things in KVM is, premature, irrelevant, and/or, FUD.  No one
> proposed such changes, so I am highlighting this fact to bring the
> thread back on topic.  That KVM talk is merely a distraction at this
> point in time.
>    

s/kvm/kvm stack/.  virtio/pci is part of the kvm stack, even if it is 
not part of kvm itself.  If vbus/venet were to be merged, users and 
developers would have to choose one or the other.  That's the 
fragmentation I'm worried about.  And you can prefix that with "fact:" 
as well.

>> We all love faster code and better management interfaces and tons
>> of your prior patches got accepted by Avi. This time you didnt even
>> _try_ to improve virtio.
>>      
> Im sorry, but you are mistaken:
>
> http://lkml.indiana.edu/hypermail/linux/kernel/0904.2/02443.html
>    

That does nothing to improve virtio.  Existing guests (Linux and 
Windows) which support virtio will cease to work if the host moves to 
vbus-virtio.  Existing hosts (running virtio-pci) won't be able to talk 
to newer guests running virtio-vbus.  The patch doesn't improve 
performance without the entire vbus stack in the host kernel and a 
vbus-virtio-net-host host kernel driver.

Perhaps if you posted everything needed to make vbus-virtio work and 
perform we could compare that to vhost-net and you'll see another reason 
why vhost-net is the better approach.

> You are also wrong to say that I didn't try to avoid creating a
> downstream effort first.   I believe the public record of the mailing
> lists will back me up that I tried politely pushing this directly though
> kvm first.  It was only after Avi recently informed me that they would
> be building their own version of an in-kernel backend in lieu of working
> with me to adapt vbus to their needs that I decided to put my own
> project together.
>    

There's no way we can adapt vbus to our needs.  Don't you think we'd 
preferred it rather than writing our own?  the current virtio-net issues 
are hurting us.

Our needs are compatibility, performance, and managability.  vbus fails 
all three, your impressive venet numbers notwithstanding.

> What should I have done otherwise, in your opinion?
>    

You could come up with uses where vbus truly is superior to 
virtio/pci/whatever (not words about etch constraints).  Showing some of 
those non-virt uses, for example.  The fact that your only user 
duplicates existing functionality doesn't help.


>> And fragmentation matters quite a bit. To Linux users, developers,
>> administrators, packagers it's a big deal whether two overlapping
>> pieces of functionality for the same thing exist within the same
>> kernel.
>>      
> So the only thing that could be construed as overlapping here is venet
> vs virtio-net. If I dropped the contentious venet and focused on making
> a virtio-net backend that we can all re-use, do you see that as a path
> of compromise here?
>    

That's a step in the right direction.

>> I certainly dont want that. Instead we (at great expense and work)
>> try to reach the best technical solution.
>>      
> This is all I want, as well.
>    

Note whenever I mention migration, large guests, or Windows you say 
these are not your design requirements.  The best technical solution 
will have to consider those.

>> If the community wants this then why cannot you convince one of the
>> most prominent representatives of that community, the KVM
>> developers?
>>      
> Its a chicken and egg at times.  Perhaps the KVM developers do not have
> the motivation or time to properly consider such a proposal _until_ the
> community presents its demand.

I've spent quite a lot of time arguing with you, no doubt influenced by 
the fact that you can write a lot faster than I can read.

>> Furthermore, 99% of your work is KVM
>>      
> Actually, no.  Almost none of it is.  I think there are about 2-3
> patches in the series that touch KVM, the rest are all original (and
> primarily stand-alone code).  AlacrityVM is the application of kvm and
> vbus (and, of course, Linux) together as a complete unit, but I do not
> try to hide this relationship.
>
> By your argument, KVM is 99% QEMU+Linux. ;)
>    

That's one of the kvm strong points...

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
