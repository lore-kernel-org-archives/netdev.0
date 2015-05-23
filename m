From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipv4: Avoid crashing in ip_error
Date: Sat, 23 May 2015 21:48:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1505232131230.1796@ja.home.ssi.bg>
References: <2b6d6ab2d8c35af3be55c82e507f5376@vittgam.net> <20150520025428.GA23304@kroah.com> <b5abf7328b22373e4ec18bd6da479431@vittgam.net> <06f5f10e9ee831f5a839c6ea24b94f64@vittgam.net> <d146b8b8a69462ced89a384e6be85b28@vittgam.net>
 <4cb068397127c2b2baee1f021b014b11@vittgam.net> <da006bc9072931406270f0fdda06045d@vittgam.net> <6056363be65a2c129551518da94bff20@vittgam.net> <87a8wx97er.fsf@x220.int.ebiederm.org> <ff82713d6862786de9784bd3c9c06bfa@vittgam.net> <20150522040453.GC8530@1wt.eu>
 <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org> <alpine.LFD.2.11.1505231158240.1796@ja.home.ssi.bg> <87oalb2w8l.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>,
	security@kernel.org, Greg KH <greg@kroah.com>, luto@amacapital.net,
	Willy Tarreau <w@1wt.eu>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46325 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757984AbbEWStj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2015 14:49:39 -0400
In-Reply-To: <87oalb2w8l.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 23 May 2015, Eric W. Biederman wrote:

> Perhaps it is possible to transmit into a veth pair even when the
> carrier is down?  Which could be a bug in the veth driver.

	Not sure if that can help but both RCU_INIT_POINTER
calls in veth_dellink can be before the unregister_netdevice_queue
ones. May be it will help for the case when veth_dellink is
called with head=NULL. As result, veth_xmit will free all
flying skbs to peer that is unregistered first.

Regards

--
Julian Anastasov <ja@ssi.bg>
