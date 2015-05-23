From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipv4: Avoid crashing in ip_error
Date: Sat, 23 May 2015 12:20:05 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1505231158240.1796@ja.home.ssi.bg>
References: <2b6d6ab2d8c35af3be55c82e507f5376@vittgam.net> <20150520025428.GA23304@kroah.com> <b5abf7328b22373e4ec18bd6da479431@vittgam.net> <06f5f10e9ee831f5a839c6ea24b94f64@vittgam.net> <d146b8b8a69462ced89a384e6be85b28@vittgam.net>
 <4cb068397127c2b2baee1f021b014b11@vittgam.net> <da006bc9072931406270f0fdda06045d@vittgam.net> <6056363be65a2c129551518da94bff20@vittgam.net> <87a8wx97er.fsf@x220.int.ebiederm.org> <ff82713d6862786de9784bd3c9c06bfa@vittgam.net> <20150522040453.GC8530@1wt.eu>
 <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>,
	security@kernel.org, Greg KH <greg@kroah.com>, luto@amacapital.net,
	Willy Tarreau <w@1wt.eu>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:42638 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755713AbbEWJUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2015 05:20:54 -0400
In-Reply-To: <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 22 May 2015, Eric W. Biederman wrote:

> ip_error does not check if in_dev is NULL before dereferencing it.
> 
> IThe following sequence of calls is possible:
> CPU A                          CPU B
> ip_rcv_finish
>     ip_route_input_noref()
>         ip_route_input_slow()
>                                inetdev_destroy()
>     dst_input()
> 
> With the result that a network device can be destroyed while processing
> an input packet.

	How can that happen in practice? May be network
driver is missing a napi_disable() call in ndo_stop()?
napi_disable is supposed to wait backlog before NETDEV_DOWN
and NETDEV_UNREGISTER (where inetdev_destroy is called) handlers
are notified. Any link to original crash report, info for used
driver, etc?

	After commit 8030f54499925d ("[IPV4] devinet: Register inetdev 
earlier.") dev->ip_ptr is always present while packets are
processed, only in_dev->ifa_list can be NULL.

Regards

--
Julian Anastasov <ja@ssi.bg>
