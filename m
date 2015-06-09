From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 1/2] Renesas Ethernet AVB driver proper
Date: Mon, 08 Jun 2015 17:12:46 -0700
Message-ID: <1433808766.29864.70.camel@edumazet-glaptop2.roam.corp.google.com>
References: <55760CB0.1020503@cogentembedded.com>
	 <20150608.151954.191885697349673611.davem@davemloft.net>
	 <55761A08.1050503@cogentembedded.com>
	 <20150608.154326.2037112726253299896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	mitsuhiro.kimura.kc@renesas.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20150608.154326.2037112726253299896.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-06-08 at 15:43 -0700, David Miller wrote:
> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Date: Tue, 09 Jun 2015 01:41:12 +0300
> 
> > On 06/09/2015 01:19 AM, David Miller wrote:
> > 
> >> It's completely implemented in software, you don't need to do anything
> >> other than properly invoke napi_gro_receive().
> > 
> >    Not even set NETIF_F_GRO?
> 
> Yes, you have to set that by default for it to go.  Thankfully this is
> also "in software" ;-)


More precisely, drivers do not have to care about this flag.

They only have to call napi_gro_receive().

core networking sets GRO flag by default in register_netdevice() for all
network devices.


#define NETIF_F_SOFT_FEATURES   (NETIF_F_GSO | NETIF_F_GRO)

vi +6512 net/core/dev.c

        /* Transfer changeable features to wanted_features and enable
         * software offloads (GSO and GRO).
         */
        dev->hw_features |= NETIF_F_SOFT_FEATURES;
        dev->features |= NETIF_F_SOFT_FEATURES;



