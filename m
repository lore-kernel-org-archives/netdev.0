From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Fri, 25 Mar 2016 00:37:59 +0000
Message-ID: <alpine.LFD.2.20.1603250029090.1789@ec-desktop.uk.level5networks.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain> <20160318232522.14955.13475.stgit@localhost.localdomain> <56F17A13.8090701@solarflare.com> <CAKgT0Ud9uPG+9AdT47Q1VygLBnjygyY29sRf=y4Pqe=f2e+bkw@mail.gmail.com> <56F19FAA.3090005@solarflare.com>
 <CAKgT0UcAuOrBTcmj1ue8mK=j4dCqr-0bydHhRb+ghS1cZaUqrw@mail.gmail.com> <56F2C3F8.8070308@solarflare.com> <CAKgT0Uei6YrWRPaov3LAFrOima=o4+V4mQcFih-rHZ+w-x4hwA@mail.gmail.com> <56F30523.8080108@solarflare.com> <CAKgT0UfgKwSRjMwRHbDNawAyJ3jvz937j1jxGvJWRaD39bSSeQ@mail.gmail.com>
 <56F3200C.20200@solarflare.com> <CAKgT0UfyOc4tYhZq7CC5G4S5HdzPW3iSifdcwe20Vxsqu8C3LQ@mail.gmail.com> <56F41FFF.7000508@solarflare.com> <CAKgT0UeW7A6cMRHm8_nEX=op_VAK5wcoYYRTNQVmMQWe02HdfA@mail.gmail.com> <56F44B56.9070206@solarflare.com>
 <CAKgT0Uc083WTmag4_B5LkVvi+iDoFtEjB0Xx4u92-Wu5S=6mzw@mail.gmail.com> <56F47171.4070003@solarflare.com> <CAKgT0UcoVV-_LrLPRoK4PLim5Nn-Z7gOV9LZF_RMXDOU8aCciA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Edward Cree <ec429@cantab.net>, Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:17482 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750965AbcCYAiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 20:38:12 -0400
In-Reply-To: <CAKgT0UcoVV-_LrLPRoK4PLim5Nn-Z7gOV9LZF_RMXDOU8aCciA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Mar 2016, Alexander Duyck wrote:
> On Thu, Mar 24, 2016 at 4:00 PM, Edward Cree <ecree@solarflare.com> wrote:
>> So: in the initial transmit path we build a coherent superframe; when we get
>> to the device, we say either "oh, device doesn't support offloads at all,
>> call GSO", or "oh, device supports this particular GSO type for TSO, so give
>> it the superframe SKB to do what it wants with", or "oh, device supports
>> GSO_PARTIAL, let's call skb_mac_gso_partial [i.e. chain of new callbacks I
>> was describing in previous email] and then give the non-coherent SKB to the
>> device".
> 
> What you are proposing is essentially forking GSO.
In a way, I suppose it is.

> I really don't
> like that.  I prefer the approach we have now where essentially GSO
> partial is something checked for at the very end and we have a few
> checks when putting together the headers so we do the right thing.
I guess both can exist, and I'll name mine something other than "GSO 
partial"...

> This is sounding very complicated.  I think we would be better off if
> you took the time to try and implement some of this yourself so you
> could see how feasible it is.
Sure, I was already intending to do that before I saw your patch series
and thought it might be able to do what I had in mind.  As it now seems
like we're envisaging different things, I'll go back to implementing
mine and wish you luck with yours.

-Ed
