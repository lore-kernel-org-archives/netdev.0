From: Fabio Estevam <festevam@gmail.com>
Subject: Re: tuntap regression in v3.9.8 and v3.10
Date: Tue, 2 Jul 2013 18:01:12 -0300
Message-ID: <CAOMZO5B7Yx7tRy8Q5wi6ngcD0FDJzKXHOEGPXyUo52+f3oUHEg@mail.gmail.com>
References: <20130702195910.GA20271@toau.bambla>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jasowang@redhat.com
To: Thomas Zeitlhofer <thomas.zeitlhofer@nt.tuwien.ac.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130702195910.GA20271@toau.bambla>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 2, 2013 at 4:59 PM, Thomas Zeitlhofer
<thomas.zeitlhofer@nt.tuwien.ac.at> wrote:
> Commit "tuntap: set SOCK_ZEROCOPY flag during open" introduces a
> regression which is observed with live migration of qemu/kvm based
> virtual machines that are connected to an openvswitch bridge.
>
> Reverting this commit (b26c93c46a3dec25ed236d4ba6107eb4ed5d9401 in
> v3.9.8 and accordingly 19a6afb23e5d323e1245baa4e62755492b2f1200 in
> v3.10) fixes the following problem:

Should the sock_set_flag stay in tun_set_iff as it was prior to 54f968d6efd?

--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1652,6 +1652,7 @@ static int tun_set_iff(struct net *net, struct
file *file, struct ifreq *ifr)
                tun->txflt.count = 0;
                tun->vnet_hdr_sz = sizeof(struct virtio_net_hdr);

+               sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
                tun->filter_attached = false;
                tun->sndbuf = tfile->socket.sk->sk_sndbuf;

@@ -2159,8 +2160,6 @@ static int tun_chr_open(struct inode *inode,
struct file * file)
        set_bit(SOCK_EXTERNALLY_ALLOCATED, &tfile->socket.flags);
        INIT_LIST_HEAD(&tfile->next);

-       sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
-
        return 0;
 }
