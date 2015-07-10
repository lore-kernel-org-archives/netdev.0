From: Ming Lin <mlin@kernel.org>
Subject: Re: [PATCH] vhost-blk: Add vhost-blk support v6
Date: Fri, 10 Jul 2015 15:50:33 -0700
Message-ID: <CAF1ivSZMseSWkwDJEmviHRDPLxEtPnkZZ0WL8qtZJYb7RaU-rA@mail.gmail.com>
References: <1354412033-32372-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	KVM General <kvm@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	lkml <linux-kernel@vger.kernel.org>,
	networking <netdev@vger.kernel.org>
To: Asias He <asias@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1354412033-32372-1-git-send-email-asias@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 1, 2012 at 5:33 PM, Asias He <asias@redhat.com> wrote:
> vhost-blk is an in-kernel virito-blk device accelerator.
>
> Due to lack of proper in-kernel AIO interface, this version converts
> guest's I/O request to bio and use submit_bio() to submit I/O directly.
> So this version any supports raw block device as guest's disk image,
> e.g. /dev/sda, /dev/ram0. We can add file based image support to
> vhost-blk once we have in-kernel AIO interface. There are some work in
> progress for in-kernel AIO interface from Dave Kleikamp and Zach Brown:
>
>    http://marc.info/?l=linux-fsdevel&m=133312234313122
>
> Performance evaluation:
> -----------------------------
> LKVM: Fio with libaio ioengine on 1 Fusion IO device
> IOPS(k)    Before    After    Improvement
> seq-read   107       121      +13.0%
> seq-write  130       179      +37.6%
> rnd-read   102       122      +19.6%
> rnd-write  125       159      +27.0%
>
> QEMU: Fio with libaio ioengine on 1 Fusion IO device
> IOPS(k)    Before    After    Improvement
> seq-read   76        123      +61.8%
> seq-write  139       173      +24.4%
> rnd-read   73        120      +64.3%
> rnd-write  75        156      +108.0%
>
> QEMU: Fio with libaio ioengine on 1 Ramdisk device
> IOPS(k)    Before    After    Improvement
> seq-read   138       437      +216%
> seq-write  191       436      +128%
> rnd-read   137       426      +210%
> rnd-write  140       415      +196%
>
> QEMU: Fio with libaio ioengine on 8 Ramdisk device
> 50% read + 50% write
> IOPS(k)    Before    After    Improvement
> randrw     64/64     189/189  +195%/+195%
>
> Userspace bits:
> -----------------------------
> 1) LKVM
> The latest vhost-blk userspace bits for kvm tool can be found here:
> git@github.com:asias/linux-kvm.git blk.vhost-blk
>
> 2) QEMU
> The latest vhost-blk userspace prototype for QEMU can be found here:
> git@github.com:asias/qemu.git blk.vhost-blk
>
> Changes in v6:
> - Use inline req_page_list to reduce kmalloc
> - Switch to single thread model, thanks mst!
> - Wait until requests fired before vhost_blk_flush to be finished
>
> Changes in v5:
> - Do not assume the buffer layout
> - Fix wakeup race
>
> Changes in v4:
> - Mark req->status as userspace pointer
> - Use __copy_to_user() instead of copy_to_user() in vhost_blk_set_status()
> - Add if (need_resched()) schedule() in blk thread
> - Kill vhost_blk_stop_vq() and move it into vhost_blk_stop()
> - Use vq_err() instead of pr_warn()
> - Fail un Unsupported request
> - Add flush in vhost_blk_set_features()
>
> Changes in v3:
> - Sending REQ_FLUSH bio instead of vfs_fsync, thanks Christoph!
> - Check file passed by user is a raw block device file
>
> Acked-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Asias He <asias@redhat.com>

Hi Asias,

Is this still under development or stopped?
