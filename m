From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: problems with e1000 and jumboframes
Date: Fri, 4 Aug 2006 08:16:42 -0700
Message-ID: <41b516cb0608040816o63ac2f72q20add7619734906@mail.gmail.com>
References: <44D1FEB7.2050703@arndnet.de> <20060803135925.GA28348@2ka.mipt.ru>
	 <44D20A2F.3090005@arndnet.de> <20060803150330.GB12915@2ka.mipt.ru>
	 <Pine.LNX.4.64.0608031705560.8443@bizon.gios.gov.pl>
	 <20060803151631.GA14774@2ka.mipt.ru>
	 <41b516cb0608030857h1d55820rfd4ccd0cc56dd71d@mail.gmail.com>
	 <20060803161046.GA703@2ka.mipt.ru>
	 <41b516cb0608031332v9cc383bq37a13254f25f45a9@mail.gmail.com>
	 <20060804062008.GC413@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Krzysztof Oledzki" <olel@ans.pl>,
	"Arnd Hannemann" <arnd@arndnet.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:13594 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932357AbWHDPQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 11:16:43 -0400
Received: by ug-out-1314.google.com with SMTP id m3so77809ugc
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2006 08:16:42 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060804062008.GC413@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/3/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > You're changing the size of the buffer without telling the hardware.
> > In the interrupt context e1000 knows the size of what was DMAed into
> > the skb, but that's after the fact.  So e1000 could detect that memory
> > was corrupted, but not prevent it if you don't give it power of 2
> > buffers.  Actually, the power of 2 thing doesn't hold true for all
> > e1000 devices.  Some have 1k granularity, but not Arnd's 82540.
>
> I can not change it - code checks if requested mtu and additional size
> is less than allocated aligned buffer it tricks allocator.
> Or do you mean that even after 9k mtu was setup it is possible that card
> can receive packets up to 16k?

Yes, that's exactly what I mean.  For anything above the standard 1500
bytes the e1000 _hardware_ has no concept of MTU, only buffer length.
So even if the driver is set to an MTU of 9000, the NIC will still
receive 16k frames.  Otherwise the driver would simply allocate MTU
sized buffers.

-Chris
