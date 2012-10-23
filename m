From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: 3.7-rc2 regression : file copied to CIFS-mounted directory
 corrupted
Date: Tue, 23 Oct 2012 11:05:52 +0200
Message-ID: <1350983152.8609.1635.camel@edumazet-glaptop>
References: <33091139.64321350980240110.JavaMail.weblogic@epml04>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"edumazet@google.com" <edumazet@google.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>
To: jongman.heo@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <33091139.64321350980240110.JavaMail.weblogic@epml04>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-10-23 at 08:17 +0000, Jongman Heo wrote:

> 
> FYI, vmxnet3 driver is used for ethernet.

Yes, this driver needs some changes

#define VMXNET3_MAX_TX_BUF_SIZE  (1 << 14)

Thats 16KB

As we can now provide up to 32KB fragments we broke something.

vmxnet3_tq_xmit() needs to split large frags into 2 parts.
(And without going to skb_linearize() of course !)

Any volunteer ?

Thanks !
