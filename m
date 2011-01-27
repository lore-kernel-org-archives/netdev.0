From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 12/20] x25: remove the BKL
Date: Thu, 27 Jan 2011 21:07:44 +1100
Message-ID: <AANLkTim=d4Tok-ri1BozZUfBFS=rofaodN8ZBA5AjKKd@mail.gmail.com>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de>
	<1295993854-4971-13-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295993854-4971-13-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Left it running and put about 3.0G through x.25, it was running fine
until after about 20 hours.
I was stopping the test programs and hit this.

Jan 27 20:18:34 jaunty kernel: [80403.945790] PGD 1d8b00067 PUD 1ddec30=
67 PMD 0
Jan 27 20:18:34 jaunty kernel: [80403.945836] CPU 3
Jan 27 20:18:34 jaunty kernel: [80403.945842] Modules linked in: x25
nls_cp437 cifs binfmt_misc kvm_intel kvm snd_hda_codec_via
snd_usb_audio snd_hda_intel snd_hda_codec nouveau snd_pcm_oss
snd_mixer_oss snd_pcm snd_seq_dummy snd_hwdep snd_usbmidi_lib
snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq
psmouse snd_timer snd_seq_device serio_raw fbcon ttm tileblit font
bitblit softcursor xhci_hcd drm_kms_helper snd drm asus_atk0110
soundcore snd_page_alloc i2c_algo_bit video usbhid hid usb_storage
r8169 pata_jmicron ahci mii libahci
Jan 27 20:18:34 jaunty kernel: [80403.946026]
Jan 27 20:18:34 jaunty kernel: [80403.946034] Pid: 28187, comm:
x25echotest Not tainted 2.6.38-rc2+ #41 P7P55D-E PRO/System Product
Name
Jan 27 20:18:34 jaunty kernel: [80403.946050] RIP:
0010:[<ffffffffa026f197>]  [<ffffffffa026f197>]
x25_sendmsg+0x1a7/0x530 [x25]
Jan 27 20:18:34 jaunty kernel: [80403.946072] RSP:
0018:ffff880228dbfcb8  EFLAGS: 00010246
Jan 27 20:18:34 jaunty kernel: [80403.946083] RAX: 0000000000000080
RBX: ffff880228dbfd70 RCX: ffff880228dbfce4
Jan 27 20:18:34 jaunty kernel: [80403.946096] RDX: 00000000fffffe00
RSI: 0000000000000000 RDI: ffff8801ba89f050
Jan 27 20:18:34 jaunty kernel: [80403.946109] RBP: ffff880228dbfd18
R08: ffff88022aa91000 R09: 0000000000000000
Jan 27 20:18:34 jaunty kernel: [80403.946482] R10: 0000000000000000
R11: 0000000000000000 R12: ffff8801ba89f000
Jan 27 20:18:34 jaunty kernel: [80403.946495] R13: 0000000000000000
R14: 0000000000000000 R15: 0000000000000000
Jan 27 20:18:34 jaunty kernel: [80403.946509] FS:
00007f09b3013700(0000) GS:ffff8800bf460000(0000)
knlGS:0000000000000000
Jan 27 20:18:34 jaunty kernel: [80403.946523] CS:  0010 DS: 0000 ES:
0000 CR0: 000000008005003b
Jan 27 20:18:34 jaunty kernel: [80403.946534] CR2: 00000000000000b4
CR3: 00000001df992000 CR4: 00000000000006e0
Jan 27 20:18:34 jaunty kernel: [80403.946547] DR0: 0000000000000000
DR1: 0000000000000000 DR2: 0000000000000000
Jan 27 20:18:34 jaunty kernel: [80403.946560] DR3: 0000000000000000
DR6: 00000000ffff0ff0 DR7: 0000000000000400
Jan 27 20:18:34 jaunty kernel: [80403.946574] Process x25echotest
(pid: 28187, threadinfo ffff880228dbe000, task ffff8801d89bc320)
Jan 27 20:18:34 jaunty kernel: [80403.946594]  ffff880200000008
0000000000000016 0000303030390009 0000000000000000
Jan 27 20:18:34 jaunty kernel: [80403.946616]  ffff880228db0000
fffffe00d8832450 0000000000000000 ffff880228dbfd38
Jan 27 20:18:34 jaunty kernel: [80403.946638]  ffff880228dbfec8
ffff880228dbfdf8 ffff8801de73b980 ffff880228dbfd70
Jan 27 20:18:34 jaunty kernel: [80403.946671]  [<ffffffff8140cdd3>]
sock_aio_write+0x183/0x1a0
Jan 27 20:18:34 jaunty kernel: [80403.946686]  [<ffffffff8110304c>] ?
__pte_alloc+0xdc/0x100
Jan 27 20:18:34 jaunty kernel: [80403.946700]  [<ffffffff81138a5a>]
do_sync_write+0xda/0x120
Jan 27 20:18:34 jaunty kernel: [80403.946713]  [<ffffffff8140d026>] ?
move_addr_to_user+0x86/0xa0
Jan 27 20:18:34 jaunty kernel: [80403.946729]  [<ffffffff812431a3>] ?
security_file_permission+0x23/0x90
Jan 27 20:18:34 jaunty kernel: [80403.946743]  [<ffffffff8113903e>]
vfs_write+0x15e/0x180
Jan 27 20:18:34 jaunty kernel: [80403.946757]  [<ffffffff81139151>]
sys_write+0x51/0x90
Jan 27 20:18:34 jaunty kernel: [80403.946771]  [<ffffffff8100bf42>]
system_call_fastpath+0x16/0x1b
Jan 27 20:18:34 jaunty kernel: [80403.946973]  RSP <ffff880228dbfcb8>
Jan 27 20:18:34 jaunty kernel: [80403.950010] ---[ end trace
36cd53b6ce0d6f4b ]---

If i have done it right, x25_sendmsg+0x1a7/0x530 is the skb_reserve
which gets inlined here.
(af_x25.c)
        /* Build a packet */
        SOCK_DEBUG(sk, "x25_sendmsg: sendto: building packet.\n");

        if ((msg->msg_flags & MSG_OOB) && len > 32)
                len =3D 32;

        size =3D len + X25_MAX_L2_LEN + X25_EXT_MIN_LEN;

        release_sock(sk);
        skb =3D sock_alloc_send_skb(sk, size, noblock, &rc);
        lock_sock(sk);

        X25_SKB_CB(skb)->flags =3D msg->msg_flags;

        skb_reserve(skb, X25_MAX_L2_LEN + X25_EXT_MIN_LEN);

        /*
         *      Put the data on the end
         */
        SOCK_DEBUG(sk, "x25_sendmsg: Copying user data\n");



objdump -dS show it at 2197 here.

static inline void skb_reserve(struct sk_buff *skb, int len)
{
        skb->data +=3D len;
        skb->tail +=3D len;
    2197:       41 83 87 b4 00 00 00    addl   $0x16,0xb4(%r15) <---
    219e:       16
    219f:       41 89 47 28             mov    %eax,0x28(%r15)
    21a3:       49 8b 87 c8 00 00 00    mov    0xc8(%r15),%rax
    21aa:       48 83 c0 16             add    $0x16,%rax
        skb_reserve(skb, X25_MAX_L2_LEN + X25_EXT_MIN_LEN);

But im not sure where to go from there...



On Wed, Jan 26, 2011 at 9:17 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>
> This replaces all instances of lock_kernel in x25
> with lock_sock, taking care to release the socket
> lock around sleeping functions (sock_alloc_send_skb
> and skb_recv_datagram). It is not clear whether
> this is a correct solution, but it seem to be what
> other protocols do in the same situation.
>
> Compile-tested only.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Andrew Hendry <andrew.hendry@gmail.com>
> Cc: linux-x25@vger.kernel.org
> Cc: netdev@vger.kernel.org
> ---
> =A0net/x25/Kconfig =A0 | =A0 =A01 -
> =A0net/x25/af_x25.c =A0| =A0 61 ++++++++++++++++---------------------=
---------------
> =A0net/x25/x25_out.c | =A0 =A07 ++++-
> =A03 files changed, 24 insertions(+), 45 deletions(-)
>
> diff --git a/net/x25/Kconfig b/net/x25/Kconfig
> index 2196e55..e6759c9 100644
> --- a/net/x25/Kconfig
> +++ b/net/x25/Kconfig
> @@ -5,7 +5,6 @@
> =A0config X25
> =A0 =A0 =A0 =A0tristate "CCITT X.25 Packet Layer (EXPERIMENTAL)"
> =A0 =A0 =A0 =A0depends on EXPERIMENTAL
> - =A0 =A0 =A0 depends on BKL # should be fixable
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0X.25 is a set of standardized network protocols, s=
imilar in scope to
> =A0 =A0 =A0 =A0 =A0frame relay; the one physical line from your box t=
o the X.25 network
> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> index ad96ee9..8f5d1bb 100644
> --- a/net/x25/af_x25.c
> +++ b/net/x25/af_x25.c
> @@ -40,7 +40,6 @@
> =A0#include <linux/errno.h>
> =A0#include <linux/kernel.h>
> =A0#include <linux/sched.h>
> -#include <linux/smp_lock.h>
> =A0#include <linux/timer.h>
> =A0#include <linux/string.h>
> =A0#include <linux/net.h>
> @@ -432,15 +431,6 @@ void x25_destroy_socket_from_timer(struct sock *=
sk)
> =A0 =A0 =A0 =A0sock_put(sk);
> =A0}
>
> -static void x25_destroy_socket(struct sock *sk)
> -{
> - =A0 =A0 =A0 sock_hold(sk);
> - =A0 =A0 =A0 lock_sock(sk);
> - =A0 =A0 =A0 __x25_destroy_socket(sk);
> - =A0 =A0 =A0 release_sock(sk);
> - =A0 =A0 =A0 sock_put(sk);
> -}
> -
> =A0/*
> =A0* =A0 =A0 Handling for system calls applied via the various interf=
aces to a
> =A0* =A0 =A0 X.25 socket object.
> @@ -647,18 +637,19 @@ static int x25_release(struct socket *sock)
> =A0 =A0 =A0 =A0struct sock *sk =3D sock->sk;
> =A0 =A0 =A0 =A0struct x25_sock *x25;
>
> - =A0 =A0 =A0 lock_kernel();
> =A0 =A0 =A0 =A0if (!sk)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>
> =A0 =A0 =A0 =A0x25 =3D x25_sk(sk);
>
> + =A0 =A0 =A0 sock_hold(sk);
> + =A0 =A0 =A0 lock_sock(sk);
> =A0 =A0 =A0 =A0switch (x25->state) {
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_STATE_0:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_STATE_2:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_disconnect(sk, 0, =
0, 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 x25_destroy_socket(sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __x25_destroy_socket(sk=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case X25_STATE_1:
> @@ -678,7 +669,8 @@ static int x25_release(struct socket *sock)
>
> =A0 =A0 =A0 =A0sock_orphan(sk);
> =A0out:
> - =A0 =A0 =A0 unlock_kernel();
> + =A0 =A0 =A0 release_sock(sk);
> + =A0 =A0 =A0 sock_put(sk);
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -1085,7 +1077,7 @@ static int x25_sendmsg(struct kiocb *iocb, stru=
ct socket *sock,
> =A0 =A0 =A0 =A0size_t size;
> =A0 =A0 =A0 =A0int qbit =3D 0, rc =3D -EINVAL;
>
> - =A0 =A0 =A0 lock_kernel();
> + =A0 =A0 =A0 lock_sock(sk);
> =A0 =A0 =A0 =A0if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_OOB|MSG_EOR|MS=
G_CMSG_COMPAT))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> @@ -1148,9 +1140,10 @@ static int x25_sendmsg(struct kiocb *iocb, str=
uct socket *sock,
>
> =A0 =A0 =A0 =A0size =3D len + X25_MAX_L2_LEN + X25_EXT_MIN_LEN;
>
> + =A0 =A0 =A0 release_sock(sk);
> =A0 =A0 =A0 =A0skb =3D sock_alloc_send_skb(sk, size, noblock, &rc);
> - =A0 =A0 =A0 if (!skb)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 lock_sock(sk);
> +
> =A0 =A0 =A0 =A0X25_SKB_CB(skb)->flags =3D msg->msg_flags;
>
> =A0 =A0 =A0 =A0skb_reserve(skb, X25_MAX_L2_LEN + X25_EXT_MIN_LEN);
> @@ -1231,26 +1224,10 @@ static int x25_sendmsg(struct kiocb *iocb, st=
ruct socket *sock,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len++;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* lock_sock() is currently only used to serialize th=
is x25_kick()
> - =A0 =A0 =A0 =A0* against input-driven x25_kick() calls. It currentl=
y only blocks
> - =A0 =A0 =A0 =A0* incoming packets for this socket and does not prot=
ect against
> - =A0 =A0 =A0 =A0* any other socket state changes and is not called f=
rom anywhere
> - =A0 =A0 =A0 =A0* else. As x25_kick() cannot block and as long as al=
l socket
> - =A0 =A0 =A0 =A0* operations are BKL-wrapped, we don't need take to =
care about
> - =A0 =A0 =A0 =A0* purging the backlog queue in x25_release().
> - =A0 =A0 =A0 =A0*
> - =A0 =A0 =A0 =A0* Using lock_sock() to protect all socket operations=
 entirely
> - =A0 =A0 =A0 =A0* (and making the whole x25 stack SMP aware) unfortu=
nately would
> - =A0 =A0 =A0 =A0* require major changes to {send,recv}msg and skb al=
location methods.
> - =A0 =A0 =A0 =A0* -> 2.5 ;)
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 lock_sock(sk);
> =A0 =A0 =A0 =A0x25_kick(sk);
> - =A0 =A0 =A0 release_sock(sk);
> =A0 =A0 =A0 =A0rc =3D len;
> =A0out:
> - =A0 =A0 =A0 unlock_kernel();
> + =A0 =A0 =A0 release_sock(sk);
> =A0 =A0 =A0 =A0return rc;
> =A0out_kfree_skb:
> =A0 =A0 =A0 =A0kfree_skb(skb);
> @@ -1271,7 +1248,7 @@ static int x25_recvmsg(struct kiocb *iocb, stru=
ct socket *sock,
> =A0 =A0 =A0 =A0unsigned char *asmptr;
> =A0 =A0 =A0 =A0int rc =3D -ENOTCONN;
>
> - =A0 =A0 =A0 lock_kernel();
> + =A0 =A0 =A0 lock_sock(sk);
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * This works for seqpacket too. The receiver has orde=
red the queue for
> =A0 =A0 =A0 =A0 * us! We do one quick check first though
> @@ -1300,8 +1277,10 @@ static int x25_recvmsg(struct kiocb *iocb, str=
uct socket *sock,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0msg->msg_flags |=3D MSG_OOB;
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Now we can treat all alike */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_sock(sk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D skb_recv_datagram(sk, flags & =
~MSG_DONTWAIT,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0flags & MSG_DONTWAIT, &rc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_sock(sk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> @@ -1338,14 +1317,12 @@ static int x25_recvmsg(struct kiocb *iocb, st=
ruct socket *sock,
>
> =A0 =A0 =A0 =A0msg->msg_namelen =3D sizeof(struct sockaddr_x25);
>
> - =A0 =A0 =A0 lock_sock(sk);
> =A0 =A0 =A0 =A0x25_check_rbuf(sk);
> - =A0 =A0 =A0 release_sock(sk);
> =A0 =A0 =A0 =A0rc =3D copied;
> =A0out_free_dgram:
> =A0 =A0 =A0 =A0skb_free_datagram(sk, skb);
> =A0out:
> - =A0 =A0 =A0 unlock_kernel();
> + =A0 =A0 =A0 release_sock(sk);
> =A0 =A0 =A0 =A0return rc;
> =A0}
>
> @@ -1581,18 +1558,18 @@ out_cud_release:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case SIOCX25CALLACCPTAPPRV: {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_kernel();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_sock(sk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sk->sk_state !=3D =
TCP_CLOSE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clear_bit(X25_ACCPT_AP=
PRV_FLAG, &x25->flags);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_kernel();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_sock(sk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case SIOCX25SENDCALLACCPT: =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_kernel();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_sock(sk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sk->sk_state !=3D =
TCP_ESTABLISHED)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* must call accptappr=
v above */
> @@ -1600,7 +1577,7 @@ out_cud_release:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25_write_internal(sk,=
 X25_CALL_ACCEPTED);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x25->state =3D X25_STA=
TE_3;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_kernel();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_sock(sk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> diff --git a/net/x25/x25_out.c b/net/x25/x25_out.c
> index d00649f..f1a6ff1 100644
> --- a/net/x25/x25_out.c
> +++ b/net/x25/x25_out.c
> @@ -68,8 +68,11 @@ int x25_output(struct sock *sk, struct sk_buff *sk=
b)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0frontlen =3D skb_headroom(skb);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (skb->len > 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((skbn =3D sock_allo=
c_send_skb(sk, frontlen + max_len,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noblock, &err)) =3D=3D NULL){
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_sock(sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skbn =3D sock_alloc_sen=
d_skb(sk, frontlen + max_len,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01, &err);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_sock(sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skbn) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (er=
r =3D=3D -EWOULDBLOCK && noblock){
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0kfree_skb(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0return sent;
> --
> 1.7.1
>
