From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
Date: Mon, 27 Sep 2010 08:42:06 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D792EC64F74F6@shsmsx502.ccr.corp.intel.com>
References: <20100915112811.GB29267@redhat.com>
 <1284970128-7343-1-git-send-email-xiaohui.xin@intel.com>
 <20100920113643.GB23898@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D792B8CAA0F6A@shsmsx502.ccr.corp.intel.com>
 <20100921131421.GA10439@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D792D171853DF@shsmsx502.ccr.corp.intel.com>
 <20100922115505.GF16423@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D792D17185524@shsmsx502.ccr.corp.intel.com>
 <20100926115018.GA19655@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45195 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757580Ab0I0Ams convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 20:42:48 -0400
In-Reply-To: <20100926115018.GA19655@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Michael S. Tsirkin [mailto:mst@redhat.com]
>Sent: Sunday, September 26, 2010 7:50 PM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>jdike@linux.intel.com
>Subject: Re: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
>
>On Thu, Sep 23, 2010 at 08:56:33PM +0800, Xin, Xiaohui wrote:
>> >-----Original Message-----
>> >From: Michael S. Tsirkin [mailto:mst@redhat.com]
>> >Sent: Wednesday, September 22, 2010 7:55 PM
>> >To: Xin, Xiaohui
>> >Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>> >mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>> >jdike@linux.intel.com
>> >Subject: Re: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
>> >
>> >On Wed, Sep 22, 2010 at 07:41:36PM +0800, Xin, Xiaohui wrote:
>> >> >-----Original Message-----
>> >> >From: Michael S. Tsirkin [mailto:mst@redhat.com]
>> >> >Sent: Tuesday, September 21, 2010 9:14 PM
>> >> >To: Xin, Xiaohui
>> >> >Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>> >> >mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>> >> >jdike@linux.intel.com
>> >> >Subject: Re: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
>> >> >
>> >> >On Tue, Sep 21, 2010 at 09:39:31AM +0800, Xin, Xiaohui wrote:
>> >> >> >From: Michael S. Tsirkin [mailto:mst@redhat.com]
>> >> >> >Sent: Monday, September 20, 2010 7:37 PM
>> >> >> >To: Xin, Xiaohui
>> >> >> >Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>> >> >> >mingo@elte.hu; davem@davemloft.net; herbert@gondor.hengli.com.au;
>> >> >> >jdike@linux.intel.com
>> >> >> >Subject: Re: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
>> >> >> >
>> >> >> >On Mon, Sep 20, 2010 at 04:08:48PM +0800, xiaohui.xin@intel.com wrote:
>> >> >> >> From: Xin Xiaohui <xiaohui.xin@intel.com>
>> >> >> >>
>> >> >> >> ---
>> >> >> >> Michael,
>> >> >> >> I have move the ioctl to configure the locked memory to vhost
>> >> >> >
>> >> >> >It's ok to move this to vhost but vhost does not
>> >> >> >know how much memory is needed by the backend.
>> >> >>
>> >> >> I think the backend here you mean is mp device.
>> >> >> Actually, the memory needed is related to vq->num to run zero-copy
>> >> >> smoothly.
>> >> >> That means mp device did not know it but vhost did.
>> >> >
>> >> >Well, this might be so if you insist on locking
>> >> >all posted buffers immediately. However, let's assume I have a
>> >> >very large ring and prepost a ton of RX buffers:
>> >> >there's no need to lock all of them directly:
>> >> >
>> >> >if we have buffers A and B, we can lock A, pass it
>> >> >to hardware, and when A is consumed unlock A, lock B
>> >> >and pass it to hardware.
>> >> >
>> >> >
>> >> >It's not really critical. But note we can always have userspace
>> >> >tell MP device all it wants to know, after all.
>> >> >
>> >> Ok. Here are two values we have mentioned, one is how much memory
>> >> user application wants to lock, and one is how much memory locked
>> >> is needed to run smoothly. When net backend is setup, we first need
>> >> an ioctl to get how much memory is needed to lock, and then we call
>> >> another ioctl to set how much it want to lock. Is that what's in your mind?
>> >
>> >That's fine.
>> >
>> >> >> And the rlimt stuff is per process, we use current pointer to set
>> >> >> and check the rlimit, the operations should be in the same process.
>> >> >
>> >> >Well no, the ring is handled from the kernel thread: we switch the mm to
>> >> >point to the owner task so copy from/to user and friends work, but you
>> >> >can't access the rlimit etc.
>> >> >
>> >> Yes, the userspace and vhost kernel is not the same process. But we can
>> >> record the task pointer as mm.
>> >
>> >So you will have to store mm and do device->mm, not current->mm.
>> >Anyway, better not touch mm on data path.
>> >
>> >> >> Now the check operations are in vhost process, as mp_recvmsg() or
>> >> >> mp_sendmsg() are called by vhost.
>> >> >
>> >> >Hmm, what do you mean by the check operations?
>> >> >send/recv are data path operations, they shouldn't
>> >> >do any checks, should they?
>> >> >
>> >> As you mentioned what infiniband driver done:
>> >>         down_write(&current->mm->mmap_sem);
>> >>
>> >>         locked     = npages + current->mm->locked_vm;
>> >>         lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>> >>
>> >>         if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
>> >>                 ret = -ENOMEM;
>> >>                 goto out;
>> >>         }
>> >>
>> >>         cur_base = addr & PAGE_MASK;
>> >>
>> >>         ret = 0;
>> >>         while (npages) {
>> >>                 ret = get_user_pages(current, current->mm, cur_base,
>> >>                                      min_t(unsigned long, npages,
>> >>                                            PAGE_SIZE / sizeof (struct page
>*)),
>> >>                                      1, !umem->writable, page_list,
>vma_list);
>> >>
>> >> I think it's a data path too.
>> >
>> >in infiniband this is used to 'register memory' which is not data path.
>> >
>> >> We do the check because get_user_pages() really pin and locked
>> >> the memory.
>> >
>> >Don't do this. Performance will be bad.
>> >Do the check once in ioctl and increment locked_vm by max amount you will use.
>> >On data path just make sure you do not exceed what userspace told you
>> >to.
>>
>> What's in my mind is that in the ioctl which to get the memory locked needed to run
>smoothly,
>> it just return a value of how much memory is needed by mp device.
>> And then in the ioctl which to set the memory locked by user space, it check the rlimit and
>> increment locked_vm by user want.
>
>Fine.
>
>> But I'm not sure how to "make sure do not exceed what
>> userspace told to". If we don't check locked_vm, what do we use to check? And Is it
>another kind of check on data path?
>
>An example: on ioctl we have incremented locked_vm by say 128K.
>We will record this number 128K in mp data structure and on data path
>verify that amount of memory we actually lock with get_user_pages_fast
>does not exceed 128K. This is not part of mm and so can use
>any locking scheme, no need to take mm semaphore.
>
>
Thanks, and later, I did do that in v11 patches. 

>
>> >
>> >>
>> >> >> So set operations should be in
>> >> >> vhost process too, it's natural.
>> >> >>
>> >> >> >So I think we'll need another ioctl in the backend
>> >> >> >to tell userspace how much memory is needed?
>> >> >> >
>> >> >> Except vhost tells it to mp device, mp did not know
>> >> >> how much memory is needed to run zero-copy smoothly.
>> >> >> Is userspace interested about the memory mp is needed?
>> >> >
>> >> >Couldn't parse this last question.
>> >> >I think userspace generally does want control over
>> >> >how much memory we'll lock. We should not just lock
>> >> >as much as we can.
>> >> >
>> >> >--
>> >> >MST
