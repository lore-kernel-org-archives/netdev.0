From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: null-ptr-deref in ip6_route_del/lock_acquire
Date: Mon, 27 Feb 2017 10:11:54 -0800
Message-ID: <CAM_iQpWFnNyk=KfFyDnYOe9iXqgTJWCysx2YMLg19ufbYGdG4g@mail.gmail.com>
References: <CAAeHK+wqCyT6BzgiKLVNbVyoDwOUyDur9Nw-C0HFYjmyAMym9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=f40304385c1ce3be7105498704ac
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wqCyT6BzgiKLVNbVyoDwOUyDur9Nw-C0HFYjmyAMym9A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--f40304385c1ce3be7105498704ac
Content-Type: text/plain; charset=UTF-8

On Mon, Feb 27, 2017 at 7:28 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit e5d56efc97f8240d0b5d66c03949382b6d7e5570 (Feb 26).
>
> A reproducer and .config are attached.
>
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 0 PID: 4045 Comm: a.out Not tainted 4.10.0+ #54
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88006b6bac00 task.stack: ffff88006a688000
> RIP: 0010:__lock_acquire+0xac4/0x3270 kernel/locking/lockdep.c:3224
> RSP: 0018:ffff88006a68f250 EFLAGS: 00010006
> RAX: dffffc0000000000 RBX: dffffc0000000000 RCX: 0000000000000000
> RDX: 0000000000000006 RSI: 0000000000000000 RDI: 1ffff1000d4d1ea4
> RBP: ffff88006a68f788 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000030 R11: 0000000000000000 R12: ffff88006b6bac00
> R13: 0000000000000000 R14: ffffffff86e64ec0 R15: 0000000000000001
> FS:  00007fda492ff700(0000) GS:ffff88006ca00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000208c4000 CR3: 000000006a7e9000 CR4: 00000000000006f0
> Call Trace:
>  lock_acquire+0x241/0x580 kernel/locking/lockdep.c:3753
>  __raw_write_lock_bh ./include/linux/rwlock_api_smp.h:203
>  _raw_write_lock_bh+0x3a/0x50 kernel/locking/spinlock.c:319
>  __ip6_del_rt_siblings net/ipv6/route.c:2177
>  ip6_route_del+0x4dd/0xa70 net/ipv6/route.c:2257
>  ipv6_route_ioctl+0x62d/0x790 net/ipv6/route.c:2620
>  inet6_ioctl+0xef/0x1e0 net/ipv6/af_inet6.c:520
>  sock_do_ioctl+0x65/0xb0 net/socket.c:895
>  sock_ioctl+0x28f/0x440 net/socket.c:993
>  vfs_ioctl fs/ioctl.c:43
>  do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:204

The attached patch fixes this crash, but I am not sure if it is the
best way to fix this bug yet...

Thanks.

--f40304385c1ce3be7105498704ac
Content-Type: text/plain; charset=US-ASCII; name="ip6-route.diff"
Content-Disposition: attachment; filename="ip6-route.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_izof83ra2

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L3JvdXRlLmMgYi9uZXQvaXB2Ni9yb3V0ZS5jCmluZGV4IGY1
NGY0MjYuLjNkMWIyNjAgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3JvdXRlLmMKKysrIGIvbmV0L2lw
djYvcm91dGUuYwpAQCAtMjIxNiwxMiArMjIxNiwxMyBAQCBzdGF0aWMgaW50IF9faXA2X2RlbF9y
dF9zaWJsaW5ncyhzdHJ1Y3QgcnQ2X2luZm8gKnJ0LCBzdHJ1Y3QgZmliNl9jb25maWcgKmNmZykK
IAogc3RhdGljIGludCBpcDZfcm91dGVfZGVsKHN0cnVjdCBmaWI2X2NvbmZpZyAqY2ZnKQogewor
CXN0cnVjdCBuZXQgKm5ldCA9IGNmZy0+ZmNfbmxpbmZvLm5sX25ldDsKIAlzdHJ1Y3QgZmliNl90
YWJsZSAqdGFibGU7CiAJc3RydWN0IGZpYjZfbm9kZSAqZm47CiAJc3RydWN0IHJ0Nl9pbmZvICpy
dDsKIAlpbnQgZXJyID0gLUVTUkNIOwogCi0JdGFibGUgPSBmaWI2X2dldF90YWJsZShjZmctPmZj
X25saW5mby5ubF9uZXQsIGNmZy0+ZmNfdGFibGUpOworCXRhYmxlID0gZmliNl9nZXRfdGFibGUo
bmV0LCBjZmctPmZjX3RhYmxlKTsKIAlpZiAoIXRhYmxlKQogCQlyZXR1cm4gZXJyOwogCkBAIC0y
MjQ3LDYgKzIyNDgsOCBAQCBzdGF0aWMgaW50IGlwNl9yb3V0ZV9kZWwoc3RydWN0IGZpYjZfY29u
ZmlnICpjZmcpCiAJCQkJY29udGludWU7CiAJCQlpZiAoY2ZnLT5mY19wcm90b2NvbCAmJiBjZmct
PmZjX3Byb3RvY29sICE9IHJ0LT5ydDZpX3Byb3RvY29sKQogCQkJCWNvbnRpbnVlOworCQkJaWYg
KHJ0ID09IG5ldC0+aXB2Ni5pcDZfbnVsbF9lbnRyeSkKKwkJCQljb250aW51ZTsKIAkJCWRzdF9o
b2xkKCZydC0+ZHN0KTsKIAkJCXJlYWRfdW5sb2NrX2JoKCZ0YWJsZS0+dGI2X2xvY2spOwogCg==
--f40304385c1ce3be7105498704ac--
