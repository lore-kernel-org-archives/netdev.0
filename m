From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 2 Jun 2009 23:37:23 +0200
Message-ID: <20090602213723.GB2850@ami.dom.local>
References: <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com> <20090528211258.GA3658@ami.dom.local> <298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com> <20090530200756.GF3166@ami.dom.local> <298f5c050906020312r514c4638sfa2b504f55d71bc1@mail.gmail.com> <298f5c050906020445n3941b4ceic1167a4a028005bf@mail.gmail.com> <20090602123635.GC4239@ff.dom.local> <4A251EEE.4060903@trash.net> <20090602130857.GA7690@ff.dom.local> <4A252714.2020008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:1692 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbZFBVhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:37:46 -0400
Received: by fg-out-1718.google.com with SMTP id d23so966315fga.17
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2009 14:37:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A252714.2020008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 02, 2009 at 03:20:20PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Tue, Jun 02, 2009 at 02:45:34PM +0200, Patrick McHardy wrote:
>>> I didn't follow the full discussion, so I'm not sure which kind of
>>> arithmetic error you're attempting to cure. For the HFSC scaling
>>> factors, please just keep in mind that its also supposed to be
>>> very accurate at low bandwidths.
>>
>> It's all here:
>>
>> http://permalink.gmane.org/gmane.linux.network/129301
>
> I've read through the mails where you suggested to change the scaling
> factors. I wasn't able to find the reasoning (IOW: where does it
> overflow or loose precision in which case) though.

I described the reasoning here:
http://permalink.gmane.org/gmane.linux.network/128189

Of course, we could try some other solution than changing the scaling.
I considered a possibility to do it internally in htb, even with
skipping rate tables, but the change of the scaling seems to be the
most generic way (alas there are some odd compatibility issues in
iproute/tc like TIME_UNITS_PER_SEC or "if (nom == 1000000)" to make
it really consistent/readable).

Jarek P.
