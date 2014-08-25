From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
Date: Mon, 25 Aug 2014 12:48:08 +0200
Message-ID: <CAFLxGvx5_JSb7sRPXY01d+eNJ4p4fk=MySGyui91KNbdyLyQ_g@mail.gmail.com>
References: <20140819123655.GC12160@sucs.org>
 <8dcf334714c44eeda54ecb129479719b@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140820034116.GA3407@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jason Wang <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "David S. Miller" <davem@davemloft.net>, Daniel Borkmann <dborkman@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: Sitsofe Wheeler <sitsofe@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140820034116.GA3407@sucs.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

 via


On Wed, Aug 20, 2014 at 5:41 AM, Sitsofe Wheeler <sitsofe@gmail.com> wrote:
> Aug 20 04:04:41 ubuntuhv kernel: [    9.230399] random: nonblocking pool is initialized
> Aug 20 04:04:41 ubuntuhv kernel: [   10.338487] EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro
> Aug 20 04:04:41 ubuntuhv kernel: [   11.099094] hv_storvsc vmbus_0_1: cmd 0x85 scsi status 0x2 srb status 0x6
> Aug 20 04:04:41 ubuntuhv kernel: [   11.099901] hv_storvsc vmbus_0_1: cmd 0x85 scsi status 0x2 srb status 0x6
> Aug 20 04:04:43 ubuntuhv kernel: [   12.999830] psmouse serio1: trackpoint: IBM TrackPoint firmware: 0x01, buttons: 0/0
> Aug 20 03:55:47 ubuntuhv kernel: [   13.003659] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio1/input/input4
> Aug 20 03:57:28 ubuntuhv kernel: [  113.711832] hv_netvsc vmbus_0_14: net device safe to remove
> Aug 20 03:57:28 ubuntuhv kernel: [  113.713882] hv_netvsc: hv_netvsc channel opened successfully
> Aug 20 03:57:29 ubuntuhv kernel: [  114.961312] hv_netvsc vmbus_0_14: Send section size: 6144, Section count:2560
> Aug 20 03:57:29 ubuntuhv kernel: [  114.962711] hv_netvsc vmbus_0_14: Device MAC 00:15:5d:6f:02:af link state up
> Aug 20 03:57:34 ubuntuhv kernel: [  120.027718] hv_netvsc vmbus_0_14: net device safe to remove
> Aug 20 03:57:34 ubuntuhv kernel: [  120.030047] hv_netvsc: hv_netvsc channel opened successfully
> Aug 20 03:57:34 ubuntuhv kernel: [  120.035422] hv_netvsc vmbus_0_14 eth0: unable to establish receive buffer's gpadl
> Aug 20 03:57:34 ubuntuhv kernel: [  120.039778] hv_netvsc vmbus_0_14 eth0: unable to connect to NetVSP - 4
> Aug 20 03:57:34 ubuntuhv kernel: [  120.039818] ------------[ cut here ]------------
> Aug 20 03:57:34 ubuntuhv kernel: [  120.039832] kernel BUG at drivers/hv/channel.c:504!

This is one is also a rude BUG_ON:
        ret = vmbus_post_msg(msg, sizeof(struct vmbus_channel_close_channel));

        BUG_ON(ret != 0);

vmbus_post_msg() hv_post_message() can easily return !0.
i.e. if this kmalloc() fails:
        addr = (unsigned long)kmalloc(sizeof(struct aligned_input), GFP_ATOMIC);
        if (!addr)
                return -ENOMEM;

-- 
Thanks,
//richard
