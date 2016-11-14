From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5] cadence: Add LSO support.
Date: Mon, 14 Nov 2016 06:35:09 -0800
Message-ID: <1479134109.8455.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <BN3PR07MB2516C30913D2FB8D4788071AC9BC0@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rafal Ozieblo <rafalo@cadence.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR07MB2516C30913D2FB8D4788071AC9BC0@BN3PR07MB2516.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-11-14 at 09:32 +0000, Rafal Ozieblo wrote:
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: 10 listopada 2016 18:01
> To: Rafal Ozieblo
> Cc: nicolas.ferre@atmel.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next v5]] cadence: Add LSO support.
> 
> From: Rafal Ozieblo <rafalo@cadence.com>
> Date: Wed, 9 Nov 2016 13:41:02 +0000
> 
> > First, please remove the spurious closing bracket in your Subject line in future submittions.
> >
> >> +	if (is_udp) /* is_udp is only set when (is_lso) is checked */
> >> +		/* zero UDP checksum, not calculated by h/w for UFO */
> >> +		udp_hdr(skb)->check = 0;
> >
> > This is really not ok.
> > 
> > If UFO is in use it should not silently disable UDP checksums.
> > 
> > If you cannot support UFO with proper checksumming, then you cannot enable support for that feature.
> 
> According Cadence Gigabit Ethernet MAC documentation:
> 
> "Hardware will not calculate the UDP checksum or modify the UDP checksum field. Therefore software
> must set a value of zero in the checksum field in the UDP header (in the first payload buffer)
> to indicate to the receiver that the UDP datagram does not include a checksum."
> 
> It is hardware requirement.

Then do not claim NETIF_F_UFO suport in the driver, if hardware is
absolutely not capable of handling this.

Linux stack will provide proper udp checksum.

Almost no driver sets NETIF_F_UFO.
