From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH] Consolidate shared code between enic and fnic drivers.
Date: Thu, 18 Jun 2009 12:45:47 -0500
Message-ID: <4A3A7D4B.5050204@cs.wisc.edu>
References: <C65FC516.7747%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Reinecke <hare@suse.de>,
	James.Bottomley@HansenPartnership.com, davem@davemloft.net,
	gospo@redhat.com, abjoglek@cisco.com, jeykholt@cisco.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <C65FC516.7747%scofeldm@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scott Feldman wrote:
> On 6/18/09 10:03 AM, "Mike Christie" <michaelc@cs.wisc.edu> wrote:
> 
>> Hannes Reinecke wrote:
>>> Hmm. Seeing that we're getting more and more of these type of drivers
>>> (cf bnx2 / bnx2i / cnic, enic / fnic, and at least one other in the pipe)
>>> one does wonder whether we should establish a separate directory for
>>> these kind of things.
>>> drivers/virtual or drivers/shared springs to mind.
>>>
>>> Having them in the network directory is probably not the
>>> correct choice.
>>>
>> I think it might sometimes. I am not sure though. I think we have two
>> models. One where this common/lib/helper/shim module requires a net
>> driver/netdev and one where it does not.
>>
>> I think vnic should go in a new dir. fnic does not require enic to
>> interact with hardare. It only needs the vnic module and vnic module
>> should not need the enic one. The fnic module does not interact with the
>> network layer's net_device.
> 
> I wanted to break vnic out into a new dir, but I couldn't figure out where
> this new dir lives.  I considered drivers/net/vnic, drivers/net/enic/vnic,
> and drivers/vnic.  But none seemed right so I just left the vnic files in
> the enic dir and built two modules there.  The fnic linkage is awkward, but
> it works.  I like Hannes suggestion of drivers/shared/vnic (or
> drivers/shared/cisco_vnic per Ben), especially if there are other drivers in
> the tree that could use the drivers/shared dir today.
> 

For the includes then, do we put them in include/shared/cisco_vnic or do 
we do that EXTRA_CFLAGS += -Idrivers/shared/cisco_vnic? In that patch 
for fnic/vnic/enic I sent a while back I did the EXTRA_CFLAGS, only 
because that is how cxgb3/iw_cxgb3 was doing it. I am not sure if that 
is nice or not. It was on the TODO to check it out.
