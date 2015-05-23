From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv4: Avoid crashing in ip_error
Date: Sat, 23 May 2015 14:09:09 -0700
Message-ID: <1432415349.4060.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2b6d6ab2d8c35af3be55c82e507f5376@vittgam.net>
	 <20150520025428.GA23304@kroah.com>
	 <b5abf7328b22373e4ec18bd6da479431@vittgam.net>
	 <06f5f10e9ee831f5a839c6ea24b94f64@vittgam.net>
	 <d146b8b8a69462ced89a384e6be85b28@vittgam.net>
	 <4cb068397127c2b2baee1f021b014b11@vittgam.net>
	 <da006bc9072931406270f0fdda06045d@vittgam.net>
	 <6056363be65a2c129551518da94bff20@vittgam.net>
	 <87a8wx97er.fsf@x220.int.ebiederm.org>
	 <ff82713d6862786de9784bd3c9c06bfa@vittgam.net>
	 <20150522040453.GC8530@1wt.eu> <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
	 <alpine.LFD.2.11.1505231158240.1796@ja.home.ssi.bg>
	 <87oalb2w8l.fsf@x220.int.ebiederm.org>
	 <alpine.LFD.2.11.1505232131230.1796@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>,
	security@kernel.org, Greg KH <greg@kroah.com>, luto@amacapital.net,
	Willy Tarreau <w@1wt.eu>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36087 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754527AbbEWVJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2015 17:09:12 -0400
Received: by pdfh10 with SMTP id h10so43643948pdf.3
        for <netdev@vger.kernel.org>; Sat, 23 May 2015 14:09:11 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1505232131230.1796@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-05-23 at 21:48 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Sat, 23 May 2015, Eric W. Biederman wrote:
> 
> > Perhaps it is possible to transmit into a veth pair even when the
> > carrier is down?  Which could be a bug in the veth driver.
> 
> 	Not sure if that can help but both RCU_INIT_POINTER
> calls in veth_dellink can be before the unregister_netdevice_queue
> ones. May be it will help for the case when veth_dellink is
> called with head=NULL. As result, veth_xmit will free all
> flying skbs to peer that is unregistered first.

Good point, but note that we never call dellink() method with head==NULL
in current kernels.
