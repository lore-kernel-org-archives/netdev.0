From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: question about netif_rx
Date: Wed, 14 Aug 2013 13:44:27 +0300
Message-ID: <CAKoUAr==Ex=XAJe4=4R+BY5QaNXKMjM4EsHYbppbXOyROi2NAw@mail.gmail.com>
References: <alpine.DEB.2.02.1308111151210.2072@localhost6.localdomain6>
	<20130811155640.GA10070@electric-eye.fr.zoreil.com>
	<alpine.DEB.2.02.1308111811440.2072@localhost6.localdomain6>
	<20130813052036.GA11640@electric-eye.fr.zoreil.com>
	<alpine.DEB.2.02.1308130828550.1997@localhost6.localdomain6>
	<CAJJAcocQ59Kc9a1b=jrNSc1akLLN_74yKANMEmLVmvxoRjX4hw@mail.gmail.com>
	<20130813204131.GA4696@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Shwatrz <dshwatrz@gmail.com>,
	Julia Lawall <julia.lawall@lip6.fr>, grant.likely@linaro.org,
	rob.herring@calxeda.com, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	devicetree@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130813204131.GA4696@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
BTW, this is not the only NAPI issue here. When looking into cleanup
of resources in this driver, a call to netif_napi_del() is missing
(though there is a call to  napi_disable(), which is not enough for
proper cleanup).

Best,
Rami Rosen
http://ramirose.wix.com/ramirosen

On Tue, Aug 13, 2013 at 11:41 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> (no top-post nor lazy quote please)
>
> David Shwatrz <dshwatrz@gmail.com> :
> [...]
>> In the napi_gro_receive() we check that the device supports
>> NETIF_F_GRO, but I don't see that we inspect checksum or that
>> NETIF_F_GRO is depends on checksum.
>
> napi_gro_receive is irrelevant. Let aside tunnel, the real work happens
> in the protocol specific gro_receive handlers.
>
> However I am an happy retard and I missed that tcp gro stopped depending
> on Rx checksum since commit 861b650101eb0c627d171eb18de81dddb93d395e. :o/
>
> So, yes, napi_gro_receive could be used.
>
> --
> Ueimor
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
