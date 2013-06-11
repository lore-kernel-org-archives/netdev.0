From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 3/5] netfilter: xt_TCPMSS: Fix violation of RFC879 in
 absence of MSS option
Date: Tue, 11 Jun 2013 11:14:04 -0700
Message-ID: <51B768EC.4090504@hp.com>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org> <1370880461-4265-4-git-send-email-pablo@netfilter.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7282@saturn3.aculab.com> <20130610071954.GA13500@gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7285@saturn3.aculab.com> <20130610082739.GA14277@gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7286@saturn3.aculab.com> <20130611162525.GA11547@localhost> <4E5779AD88B2F040B8A7E83ECF544D1A016005@SJCPEX01CL02.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Phil Oester <kernel@linuxace.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Haran <Jeff.Haran@citrix.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4E5779AD88B2F040B8A7E83ECF544D1A016005@SJCPEX01CL02.citrite.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> There is likely no "right" answer for this issue, but for what it's
> worth I can report a somewhat related experience I had a few years
> ago when updating my PC at home with a new Suse distro. The machine
> had been running previous versions of Suse with my Comcast cable
> internet service just fine for several years. I downloaded the ISO
> from opensuse, burned the DVD, did the install but when it came back
> up again the internet service was quite unreliable. It would work for
> a few minutes, but then no packets would flow. I happened to run
> ifconfig eth0 and it showed an MTU of 576. It seems the version of
> the DHCP client that came with the new distro honored the DHCP MTU
> option, but Comcast was advertising DHCP offers with an MTU of 576.

Presumably then, your system rejected any incoming packet which was 
larger than the 576 byte MTU it got from the Comcast DHCP server..

I can think of two reasons for larger packets to be arriving at your 
system then:

1) UDP

2) Broken TCPs ass-u-me-ing a TCP MSS larger than 536 bytes when there 
wasn't an MSS option in the SYN(s).

Did your SuSE system send actual TCP MSS options based on the 576 byte MTU?


rick jones
