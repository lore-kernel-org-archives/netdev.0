From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Avoid infinite loop on recvmsg bug
Date: Wed, 07 Nov 2012 15:33:12 -0800
Message-ID: <1352331192.2748.10.camel@edumazet-glaptop>
References: <CAODwPW9kiG-jo=n0zedv5KT-8-gJcEUrdC3F2mAEjt78tne18g@mail.gmail.com>
	 <1352316791-16491-1-git-send-email-jwerner@chromium.org>
	 <1352317219.5552.6.camel@edumazet-glaptop>
	 <CAODwPW8mBJspF3k5SCBR-BShNvBLQpD-vyhLRh5Cq-4h=VZDgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Dave Jones <davej@redhat.com>,
	Sameer Nanda <snanda@chromium.org>,
	Mandeep Singh Baines <msb@chromium.org>
To: Julius Werner <jwerner@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAODwPW8mBJspF3k5SCBR-BShNvBLQpD-vyhLRh5Cq-4h=VZDgg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-11-07 at 13:14 -0800, Julius Werner wrote:
> > What I find very sad in all this is that you didnt mention the driver
> > that was triggering this bug.
> 
> Sorry, I was just trying to keep this thread focussed on one patch.
> The bug report that led me to this is publicly accessible at
> http://crosbug.com/35827. We have encountered the problem only once,
> on an Acer AC700 Chromebook that ran automated tests. The ethernet
> interface for the offending socket was provided by a USB-to-Ethernet
> dongle using the smsc95xx/usbnet module (v1.0.4).

This driver uses interesting skb_clone() games and skb->truesize lies :

skb->truesize = size + sizeof(struct sk_buff);

So you probably are fighting a bug we already fixed in upstream kernel.

(commit c8628155ece363 "tcp: reduce out_of_order memory use" did not
played well with cloned skbs.)

This issue was already discussed on netdev in the past.
