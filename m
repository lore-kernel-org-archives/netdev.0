From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] net: Switch tag HW extraction/insertion
Date: Fri, 31 Jul 2015 08:08:40 +0200
Message-ID: <1438322920.20182.144.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>
		<20150730.141935.723435302404122784.davem@davemloft.net>
	 <20150730.155124.2216613161860898066.davem@davemloft.net>
	 <55BAD4BD.20405@alphacore.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <florian@alphacore.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55BAD4BD.20405@alphacore.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-30 at 18:51 -0700, Florian Fainelli wrote:
> On 30/07/15 15:51, David Miller wrote:
> > From: David Miller <davem@davemloft.net>
> > Date: Thu, 30 Jul 2015 14:19:35 -0700 (PDT)
> > 
> >> This looks fine, series applied, thanks.
> > 
> > I think your control block is too large, you'll need to rework this
> > somehow.
> 
> So napi_gro_cb really is 48 bytes on 64-bits architectures (had not
> realized it was so big).
> 
> What would you recommend to do here considering that this driver is
> currently used on 32-bits platforms, but I see no reason why someone
> would no want to use this feature on a 64-bit platform, yet we are
> competing with napi_gro_cb, and adding a new skbuff member is pretty
> much a no-no? Would it be acceptable to have a new member which is ifdef
> CONFIG_NET_DSA_TAG_BRCM?
> 
> FWIW, this does provide a small 2-3% throughput increase for RX.

Which layer will read this tag after GRO processing ?

It seems you simply can use skb->cb[] like other layers : At offset 0.

BTW brcm_tag_rcv() does not even use GRO, as it calls
netif_receive_skb()
