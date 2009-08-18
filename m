From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Tue, 18 Aug 2009 22:08:27 +0300
Message-ID: <4A8AFC2B.8020406@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com> <200908182020.11126.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751509AbZHRTIT@vger.kernel.org>
In-Reply-To: <200908182020.11126.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18/2009 09:20 PM, Arnd Bergmann wrote:
>> Well, the interrupt model to name one.
>>      
> The performance aspects of your interrupt model are independent
> of the vbus proxy, or at least they should be. Let's assume for
> now that your event notification mechanism gives significant
> performance improvements (which we can't measure independently
> right now). I don't see a reason why we could not get the
> same performance out of a paravirtual interrupt controller
> that uses the same method, and it would be straightforward
> to implement one and use that together with all the existing
> emulated PCI devices and virtio devices including vhost_net.
>    

Interesting.  You could even configure those vectors using the standard 
MSI configuration mechanism; simply replace the address/data pair with 
something meaningful to the paravirt interrupt controller.

I'd have to see really hard numbers to be tempted to merge something 
like this though.  We've merged paravirt mmu, for example, and now it 
underperforms both hardware two-level paging and software shadow paging.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
