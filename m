From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 hw csum failure [was Re: sky2 large MTU problems]
Date: Tue, 30 May 2006 10:10:11 +0100
Message-ID: <6278d2220605300210u101d65a9u93354aecbcde99a@mail.gmail.com>
References: <6278d2220605240228v576dd66atdad4855b308e64bf@mail.gmail.com>
	 <20060524103820.2e213a0b@localhost.localdomain>
	 <44758881.1020106@trash.net>
	 <6278d2220605250355y316f974cl216f22d198475666@mail.gmail.com>
	 <447591DB.2020901@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>, netdev@vger.kernel.org,
	"Netfilter Developer" <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:49567 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932194AbWE3JKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 05:10:13 -0400
Received: by wr-out-0506.google.com with SMTP id i7so1057185wra
        for <netdev@vger.kernel.org>; Tue, 30 May 2006 02:10:12 -0700 (PDT)
To: "Patrick McHardy" <kaber@trash.net>
In-Reply-To: <447591DB.2020901@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25/05/06, Patrick McHardy <kaber@trash.net> wrote:
> Daniel J Blueman wrote:
> > On 25/05/06, Patrick McHardy <kaber@trash.net> wrote:
> >
> >> Daniel, is there an easy way to reproduce the checksum failure?
> >
> > In short, no. This was seen when packets may have been truncated by
> > large MTU (eg 9000) problems in the sky2 driver transmit path.
> >
> > There is a small chance that this could relate to transmitting with an
> > MTU of 9000 (possibly with receiving with an MTU of 1500 too)
>
> Unfortunately I can't test this myself because my other NICs don't
> support MTUs > 1500.
>
> > On that interface, the only rules that were being exercised were:
> >
> > iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
> > iptables -t filter -A INPUT -p tcp -m tcp --dport 445 --syn -j ACCEPT # SMB
> > iptables -t filter -A INPUT -j DROP
>
> That shouldn't cause any packet modifications. Can you trigger the
> checksum failures without netfilter?

When testing, I always run into the "kernel: sky2 lan0: rx error,
status 0x977d977d length 0" problem before anything else.

I need to eliminate the sky2 driver from the equation before I'm able
to prove if there is a problem elsewhere or not. I did have some e1000
NICs, but not any longer, so it'll have to wait until I can find a
stable scenario for my sky2 NIC...
-- 
Daniel J Blueman
