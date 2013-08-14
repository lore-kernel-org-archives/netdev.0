From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: question about netif_rx
Date: Wed, 14 Aug 2013 17:18:51 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1308141713290.2257@hadrien>
References: <alpine.DEB.2.02.1308111151210.2072@localhost6.localdomain6> <20130811155640.GA10070@electric-eye.fr.zoreil.com> <alpine.DEB.2.02.1308111811440.2072@localhost6.localdomain6> <20130813052036.GA11640@electric-eye.fr.zoreil.com>
 <alpine.DEB.2.02.1308130828550.1997@localhost6.localdomain6> <CAJJAcocQ59Kc9a1b=jrNSc1akLLN_74yKANMEmLVmvxoRjX4hw@mail.gmail.com> <20130813204131.GA4696@electric-eye.fr.zoreil.com> <CAKoUAr==Ex=XAJe4=4R+BY5QaNXKMjM4EsHYbppbXOyROi2NAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Shwatrz <dshwatrz@gmail.com>,
	Julia Lawall <julia.lawall@lip6.fr>, grant.likely@linaro.org,
	rob.herring@calxeda.com, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	devicetree@vger.kernel.org
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKoUAr==Ex=XAJe4=4R+BY5QaNXKMjM4EsHYbppbXOyROi2NAw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Aug 2013, Rami Rosen wrote:

> Hi,
> BTW, this is not the only NAPI issue here. When looking into cleanup
> of resources in this driver, a call to netif_napi_del() is missing
> (though there is a call to  napi_disable(), which is not enough for
> proper cleanup).

Actually, netif_napi_del seems to be quite underused.  At least
approximately, I would assume that every file that uses netif_napi_add
should use netif_napi_del at least once, and possible more times.  But I
find 118 .c files that use netif_napi_add, and only 35 that use
netif_napi_del.

Are there some cases where it might not be needed?

julia
