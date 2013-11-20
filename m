From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 19 Nov 2013 16:43:48 -0800
Message-ID: <1384908228.8604.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131113072257.GB10591@1wt.eu> <20131117141940.GA18569@1wt.eu>
	 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87li0kkhzx.fsf@natisbad.org>
	 <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131119174323.GH913@1wt.eu>
	 <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org>
	 <1384906129.8604.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131120003519.GA22150@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, netdev@vger.kernel.org,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:52478 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476Ab3KTAnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 19:43:52 -0500
Received: by mail-qa0-f46.google.com with SMTP id f11so2639850qae.19
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 16:43:51 -0800 (PST)
In-Reply-To: <20131120003519.GA22150@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-20 at 01:35 +0100, Willy Tarreau wrote:
> On Tue, Nov 19, 2013 at 04:08:49PM -0800, Eric Dumazet wrote:
> > On Wed, 2013-11-20 at 00:53 +0100, Arnaud Ebalard wrote:
> > 
> > > Anyway, I think if the thread keeps going on improving mvneta, I'll do
> > > all additional tests from RAM and will stop polluting netdev w/ possible
> > > sata/disk/fs issues.
> > 
> > ;)
> > 
> > Alternative would be to use netperf or iperf to not use disk at all
> > and focus on TCP/network issues only.
> 
> Yes, that's for the same reason that I continue to use inject/httpterm
> for such purposes :
>   - httpterm uses tee()+splice() to send pre-built pages without copying ;
>   - inject uses recv(MSG_TRUNC) to ack everything without copying.
> 
> Both of them are really interesting to test the hardware's capabilities
> and to push components in the middle to their limits without causing too
> much burden to the end points.
> 
> I don't know if either netperf or iperf can make use of this now, and
> I've been used to my tools, but I should take a look again.

netperf -t TCP_SENDFILE  does the zero copy at sender.

And more generally -V option does copy avoidance

(Use splice(sockfd -> nullfd) at receiver if I remember well)


Anyway, we should do the normal copy, because it might demonstrate
scheduling problems.

If you want to test raw speed, you could use pktgen ;)
