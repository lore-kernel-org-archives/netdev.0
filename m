From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Tue, 09 Oct 2012 15:29:09 +1030
Message-ID: <878vbg8cma.fsf@rustcorp.com.au>
References: <cover.1348824232.git.mst@redhat.com>
	<87vces2gxq.fsf__45058.6618776017$1349247807$gmane$org@rustcorp.com.au>
	<506C192E.5060700@redhat.com> <87bogj2j1b.fsf@rustcorp.com.au>
	<506D3610.7000103@redhat.com> <87ipaq1jtt.fsf@rustcorp.com.au>
	<506D8DD5.20904@redhat.com>
	<87391t1nkq.fsf__40391.6521034718$1349505001$gmane$org@rustcorp.com.au>
	<507029EB.2050405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Sasha Levin <levinsasha928@gmail.com>, avi@redhat.com,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
To: Paolo Bonzini <pbonzini@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <507029EB.2050405@redhat.com>
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

Paolo Bonzini <pbonzini@redhat.com> writes:
> Il 05/10/2012 07:43, Rusty Russell ha scritto:
>> That's good.  But virtio_blk's scsi command is insoluble AFAICT.  As I
>> said to Anthony, the best rules are "always" and "never", so I'd really
>> rather not have to grandfather that in.
>
> It is, but we can add a rule that if the (transport) flag
> VIRTIO_RING_F_ANY_HEADER_SG is set, the cdb field is always 32 bytes in
> virtio-blk.

Could we do that?  It's the cmd length I'm concerned about; is it always
32 in practice for some reason?

Currently qemu does:

    struct sg_io_hdr hdr;
    memset(&hdr, 0, sizeof(struct sg_io_hdr));
    hdr.interface_id = 'S';
    hdr.cmd_len = req->elem.out_sg[1].iov_len;
    hdr.cmdp = req->elem.out_sg[1].iov_base;
    hdr.dxfer_len = 0;

If it's a command which expects more output data, there's no way to
guess where the boundary is between that command and the data.

Cheers,
Rusty.
