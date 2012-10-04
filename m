From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Thu, 04 Oct 2012 15:23:33 +0200
Message-ID: <506D8DD5.20904@redhat.com>
References: <cover.1348824232.git.mst@redhat.com> <87vces2gxq.fsf__45058.6618776017$1349247807$gmane$org@rustcorp.com.au> <506C192E.5060700@redhat.com> <87bogj2j1b.fsf@rustcorp.com.au> <506D3610.7000103@redhat.com> <87ipaq1jtt.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, avi@redhat.com,
	Sasha Levin <levinsasha928@gmail.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43074 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932305Ab2JDNXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 09:23:51 -0400
In-Reply-To: <87ipaq1jtt.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 04/10/2012 14:51, Rusty Russell ha scritto:
> Paolo Bonzini <pbonzini@redhat.com> writes:
> 
>> Il 04/10/2012 02:11, Rusty Russell ha scritto:
>>>>> There's a reason I haven't done this.  I really, really dislike "my
>>>>> implemention isn't broken" feature bits.  We could have an infinite
>>>>> number of them, for each bug in each device.
>>>>
>>>> However, this bug affects (almost) all implementations and (almost) all
>>>> devices.  It even makes sense to reserve a transport feature bit for it
>>>> instead of a device feature bit.
>>>
>>> Perhaps, but we have to fix the bugs first!
>>
>> Yes. :)  Isn't that what mst's patch does?
>>
>>> As I said, my torture patch broke qemu immediately.  Since noone has
>>> leapt onto fixing that, I'll take a look now...
>>
>> I can look at virtio-scsi.
> 
> Actually, you can't, see my reply to Anthony...
> 
> Message-ID: <87lifm1y1n.fsf@rustcorp.com.au>

    struct virtio_scsi_req_cmd {
        // Read-only
        u8 lun[8];
        u64 id;
        u8 task_attr;
        u8 prio;
        u8 crn;
        char cdb[cdb_size];
        char dataout[];
        // Write-only part
        u32 sense_len;
        u32 residual;
        u16 status_qualifier;
        u8 status;
        u8 response;
        u8 sense[sense_size];
        char datain[];
    };

where cdb_size and sense_size come from configuration space.  The device
right now expects everything before dataout/datain to be in a single
descriptor, but that's in no way part of the spec.  Am I missing
something egregious?

Paolo
