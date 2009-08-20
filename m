From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Thu, 20 Aug 2009 20:25:55 +0300
Message-ID: <20090820172555.GF6749@il.ibm.com>
References: <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com> <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com> <4A8BA5AE.3030308@redhat.com> <4A8C43D3.7030002@gmail.com> <4A8C627C.70001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Patrick Mullaney <pmullaney@novell.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755091AbZHTR0o@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A8C627C.70001@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 19, 2009 at 11:37:16PM +0300, Avi Kivity wrote:

> On 08/19/2009 09:26 PM, Gregory Haskins wrote:

>>>> This is for things like the setup of queue-pairs, and the
>>>> transport of door-bells, and ib-verbs.  I am not on the team
>>>> doing that work, so I am not an expert in this area.  What I do
>>>> know is having a flexible and low-latency signal-path was deemed
>>>> a key requirement.
>>>>
>>>>        
>>> That's not a full bypass, then.  AFAIK kernel bypass has userspace
>>> talking directly to the device.
>>>      
>> Like I said, I am not an expert on the details here.  I only work
>> on the vbus plumbing.  FWIW, the work is derivative from the
>> "Xen-IB" project
>>
>> http://www.openib.org/archives/nov2006sc/xen-ib-presentation.pdf
>>
>> There were issues with getting Xen-IB to map well into the Xen
>> model.  Vbus was specifically designed to address some of those
>> short-comings.
>
> Well I'm not an Infiniband expert.  But from what I understand VMM
> bypass means avoiding the call to the VMM entirely by exposing
> hardware registers directly to the guest.

The original IB VMM bypass work predates SR-IOV (i.e., does not assume
that the adapter has multiple hardware register windows for multiple
devices). The way it worked was to split all device operations into
`privileged' and `non-privileged'. Privileged operations such as
mapping and pinning memory went through the hypervisor. Non-privileged
operations such reading or writing previously mapped memory went
directly to the adpater. Now-days with SR-IOV devices, VMM bypass
usually means bypassing the hypervisor completely.

Cheers,
Muli
-- 
Muli Ben-Yehuda | muli@il.ibm.com | +972-4-8281080
Manager, Virtualization and Systems Architecture
Master Inventor, IBM Haifa Research Laboratory
