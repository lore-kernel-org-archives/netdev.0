From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 09:51:53 +0300
Message-ID: <49D46089.5040204@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D3D7EE.4080202@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
>
>
> I think there is a slight disconnect here.  This is *exactly* what I am
> trying to do.  You can of course do this many ways, and I am not denying
> it could be done a different way than the path I have chosen.  One
> extreme would be to just slam a virtio-net specific chunk of code
> directly into kvm on the host.  Another extreme would be to build a
> generic framework into Linux for declaring arbitrary IO types,
> integrating it with kvm (as well as other environments such as lguest,
> userspace, etc), and building a virtio-net model on top of that.
>
> So in case it is not obvious at this point, I have gone with the latter
> approach.  I wanted to make sure it wasn't kvm specific or something
> like pci specific so it had the broadest applicability to a range of
> environments.  So that is why the design is the way it is.  I understand
> that this approach is technically "harder/more-complex" than the "slam
> virtio-net into kvm" approach, but I've already done that work.  All we
> need to do now is agree on the details ;)
>
>   

virtio is already non-kvm-specific (lguest uses it) and non-pci-specific 
(s390 uses it).

>> That said, I don't think we're bound today by the fact that we're in
>> userspace.
>>     
> You will *always* be bound by the fact that you are in userspace.  Its
> purely a question of "how much" and "does anyone care".    Right now,
> the anwer is "a lot (roughly 45x slower)" and "at least Greg's customers
> do".  I have no doubt that this can and will change/improve in the
> future.  But it will always be true that no matter how much userspace
> improves, the kernel based solution will always be faster.  Its simple
> physics.  I'm cutting out the middleman to ultimately reach the same
> destination as the userspace path, so userspace can never be equal.
>   

If you have a good exit mitigation scheme you can cut exits by a factor 
of 100; so the userspace exit costs are cut by the same factor.  If you 
have good copyless networking APIs you can cut the cost of copies to 
zero (well, to the cost of get_user_pages_fast(), but a kernel solution 
needs that too).

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

