From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [Pv-drivers] 3.7-rc2 regression : file copied to CIFS-mounted
 directory corrupted
Date: Tue, 23 Oct 2012 03:02:10 -0700 (PDT)
Message-ID: <1103939870.6550404.1350986530909.JavaMail.root@vmware.com>
References: <636804155.6539897.1350984018386.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org,
	edumazet@google.com, linux-kernel@vger.kernel.org,
	jongman heo <jongman.heo@samsung.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <636804155.6539897.1350984018386.JavaMail.root@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Well, actually the driver does split large frags into frags of VMXNET3_MAX_TX_BUF_SIZE bytes each.

vmxnet3_drv.c
 711         while (len) {
 712                 u32 buf_size;
 713
 714                 if (len < VMXNET3_MAX_TX_BUF_SIZE) {
 715                         buf_size = len;
 716                         dw2 |= len;
 717                 } else {
 718                         buf_size = VMXNET3_MAX_TX_BUF_SIZE;
 719                         /* spec says that for TxDesc.len, 0 == 2^14 */
 720                 }
 721
....
 743
 744                 len -= buf_size;
 745                 buf_offset += buf_size;
 746         }


----- Original Message -----
> Eric, thanks for the note. I will submit a patch to do it.
> 
> Shreyas
> 
> ----- Original Message -----
> > On Tue, 2012-10-23 at 08:17 +0000, Jongman Heo wrote:
> > 
> > > 
> > > FYI, vmxnet3 driver is used for ethernet.
> > 
> > Yes, this driver needs some changes
> > 
> > #define VMXNET3_MAX_TX_BUF_SIZE  (1 << 14)
> > 
> > Thats 16KB
> > 
> > As we can now provide up to 32KB fragments we broke something.
> > 
> > vmxnet3_tq_xmit() needs to split large frags into 2 parts.
> > (And without going to skb_linearize() of course !)
> > 
> > Any volunteer ?
> > 
> > Thanks !
> > 
> > 
> > 
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
> 
