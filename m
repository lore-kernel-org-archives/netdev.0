From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v3 2/4] net: add rx_nohandler stat counter
Date: Sun, 07 Feb 2016 12:19:28 -0800
Message-ID: <1454876368.7627.350.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454370667-2328-1-git-send-email-jarod@redhat.com>
	 <1454370667-2328-3-git-send-email-jarod@redhat.com>
	 <20160207113732.25a88cc4@xeon-e3>
	 <20160207.144648.750890874940574761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jarod@redhat.com,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160207.144648.750890874940574761.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-02-07 at 14:46 -0500, David Miller wrote:

> > Why was this userspace ABI change allowed?
> > The stats structure is exposed to user space via netlink
> > and changing the size of responses will break iproute2 commands.

I do not think it breaks anything.

iproute2 always assumed kernel was sending at least 23 u64, and does not
check at all if the kernel sends more. (or less, so iproute2 can print
garbage if kernel is malicious)

an iproute2 patch will be needed to automatically detect if new kernels
are sending more data and print it accordingly.

> > 
> > The code will be expecting one size and the response will vary and
> > break existing code.  Yes, the code should check the size
> > of the response, but it doesn't and I am sure iproute2 is not
> > the only code that does this.
> 
> Jarod, please look into this.

Running latest net-next, and old iproute2 is just fine.

# ip -s link sh dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq portid
001a11fffec30d80 state UP mode DEFAULT group default qlen 16000
    link/ether 00:1a:11:c3:0d:7f brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    533766     1875     0       0       0       135     
    TX: bytes  packets  errors  dropped carrier collsns 
    209204     1858     0       0       0       0       
