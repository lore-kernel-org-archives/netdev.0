From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Sat, 06 Oct 2012 14:54:03 +0200
Message-ID: <507029EB.2050405@redhat.com>
References: <cover.1348824232.git.mst@redhat.com>
	<87vces2gxq.fsf__45058.6618776017$1349247807$gmane$org@rustcorp.com.au>
	<506C192E.5060700@redhat.com> <87bogj2j1b.fsf@rustcorp.com.au>
	<506D3610.7000103@redhat.com> <87ipaq1jtt.fsf@rustcorp.com.au>
	<506D8DD5.20904@redhat.com>
	<87391t1nkq.fsf__40391.6521034718$1349505001$gmane$org@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Sasha Levin <levinsasha928@gmail.com>, avi@redhat.com,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87391t1nkq.fsf__40391.6521034718$1349505001$gmane$org@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Il 05/10/2012 07:43, Rusty Russell ha scritto:
>> >     struct virtio_scsi_req_cmd {
>> >         // Read-only
>> >         u8 lun[8];
>> >         u64 id;
>> >         u8 task_attr;
>> >         u8 prio;
>> >         u8 crn;
>> >         char cdb[cdb_size];
>> >         char dataout[];
>> >         // Write-only part
>> >         u32 sense_len;
>> >         u32 residual;
>> >         u16 status_qualifier;
>> >         u8 status;
>> >         u8 response;
>> >         u8 sense[sense_size];
>> >         char datain[];
>> >     };
>> >
>> > where cdb_size and sense_size come from configuration space.  The device
>> > right now expects everything before dataout/datain to be in a single
>> > descriptor, but that's in no way part of the spec.  Am I missing
>> > something egregious?
> Since you wrote it, I hope not :)

Yeah, I guess the confusion came from cdb_size and sense_size being in
configuration space.

> That's good.  But virtio_blk's scsi command is insoluble AFAICT.  As I
> said to Anthony, the best rules are "always" and "never", so I'd really
> rather not have to grandfather that in.

It is, but we can add a rule that if the (transport) flag
VIRTIO_RING_F_ANY_HEADER_SG is set, the cdb field is always 32 bytes in
virtio-blk.

Paolo
