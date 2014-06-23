From: Marc Duponcheel <marc@offline.be>
Subject: Re: r8169/r8168 slow internet upload
Date: Tue, 24 Jun 2014 00:46:14 +0200
Message-ID: <20140623224614.GA31154@offline.be>
References: <20140511231946.GA12504@offline.be>
Reply-To: Marc Duponcheel <marc@offline.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Duponcheel <marc@offline.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.offline.be ([79.132.231.86]:43544 "EHLO mail.offline.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475AbaFWXFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 19:05:07 -0400
Content-Disposition: inline
In-Reply-To: <20140511231946.GA12504@offline.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 FYI

it seems upgrade to 3.14.5 -> 3.15.1 fixed issue ...

not sure which change implements fix but, in any case:

 THANKS

On 2014 May 12, Marc Duponcheel wrote:
>  Hi all
> 
>  I have an issue with linux box acting as router (in fact forwarder)
> with 2 Realtek RTL8111/8168/8411 cards.
> 
>  In short: large file uploads are way too slow and, during such
> uploads, I see TcpRetransSegs and TcpOutRsts on sending host.
> 
>  System is bleeding edge gentoo.
> 
>  I replaced linux r8169 by vendor r8168 driver. That improved some
> uploads (see below).
> 
> 
>  - Details
>   --------
> 
> Setup is as follows (VDSL2) with down/up 50Mbps/6Mbps
> 
> 
>  intranet - server - router - modem - internet
> 
> 
> modem =
>  b-box3 technicolor box in bridge mode
> 
> router =
>  The linux box in question doing pppoe on eth towards internet (where
>  it receives an address for p-t-p to next hop) and having public /30
>  network on eth towards intranet.
> 
> server =
>  Also a bleeding edge gentoo gentoo box having one public address from
>  the /30 network (router has the other one) and the doing NAT to
>  devices on intranet.
> 
>   ** note **
> 
>   Before having the [router - modem] combo, I used a CISCO886VA-K9 box
>  and I had expected 50/6 throughput. But provider, who migrates to
>  VDSL2 vectoring, does not allow cisco on its network so I use b-box3
>  as bridge (the box they allow) and put a linux router behind.
> 
> 
>  - Symptoms
>   ---------
> 
>  I test ftp between my server and clients few or several hops away.
> 
> * r8169:
> 
>  Incoming speed is OK (50Mbps) but outgoing is only 200Kbps. 30 times
> too slow.
> 
>  Now I set eth speeds to 100Mbps (on linux-router, I never touch
> linux-server who works fine anyway for years with cisco-router):
> 
>  Outgoing speed to few hops away is 2Mbps and to many hops away still 200Kbps.
> 
> * replace r8169 with r8168:
> 
>  Outgoing to few hops away is 3Mbps and to many hops away is 1.5Mbps.
> 
>  As said I always notice TcpRetransSegs and TcpOutRsts on server. I
>  use
> # watch -n 5 'nstat | grep ^Tcp'
>  to inspect.
> 
> 
>  I see few (really few) router drops on eth Rx towards intranet. In
> fact I am not sure if those increase during upload.
> 
> 
>  If I increase txqueuelen from 1000 to 10000 on router and flush tcp
> metrics on router and server, outgoing speed starts 6Mbps but soon
> drops back to steady 3Mbps and 1.5Mbps. I reverted back to 1000.
> 
>  FYI: ookla speedtests on all hosts show 50/6 (only with with r8168 on
>    router), and, perhaps, for most work, everything is fine, but large
>    file uploads, in particular from our ftp server to internet many
>    hops away, is still 4 times too slow.
> 
>  If I do
> watch 'ethtool --statistics iface | grep -v ' 0''
>  on both router ethernets and server ethernet towards internet, I do not see
> any error count increase.
> 
>  Note that realtek driver does not support setting eth flow control so
> I could not try to turn it off (not that I expect it to help).
> 
>  Also PPP MTU/MRU are 1492 and TCPMSS clamp to PMTU is on server and router
> (but that did not matter).
> 
>  - Conclusions
>   ------------
> 
>  Setup is both driver and eth-speed sensitive. I also suspect TCP to
> kick in to compensate for whatever issues.
> 
> 
>  - Questions
>   ----------
> 
>  Am I missing something obvious? Or are the RTL8111/8168/8411
> cards/drivers not good for this setup? Any other hints? I am happy to
> do whatever tests and provide whatever outputs that may help drive
> discussion.
> 
> 
>  *** thanks ****

--
 Marc Duponcheel
 Velodroomstraat 74 - 2600 Berchem - Belgium
 +32 (0)478 68.10.91 - marc@offline.be
