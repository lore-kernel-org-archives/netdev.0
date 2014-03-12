From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace and
 a system freeze
Date: Wed, 12 Mar 2014 09:38:27 +0100
Message-ID: <20140312083827.GE32371@secunet.com>
References: <20140310014452.144b0491@north>
 <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
 <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140310131909.33a3042c@north>
 <1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140311014649.1716bde1@north>
 <20140311120059.GB32371@secunet.com>
 <1394541626.21721.24.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140311132030.GD32371@secunet.com>
 <20140311153029.1de9d6e9@north>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	Fan Du <fan.du@windriver.com>
To: Jakub =?utf-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58041 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756336AbaCLIia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 04:38:30 -0400
Content-Disposition: inline
In-Reply-To: <20140311153029.1de9d6e9@north>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 03:30:29PM +0100, Jakub Kici=C5=84ski wrote:
>=20
> Tested with del_timer_sync and unregister_hotcpu_notifier:
>=20
> void flow_cache_fini(struct net *net)
> {
> 	int i;
> 	struct flow_cache *fc =3D &net->xfrm.flow_cache_global;
>=20
> 	unregister_hotcpu_notifier(&fc->hotcpu_notifier);
> 	del_timer_sync(&fc->rnd_timer);
>=20
> 	for_each_possible_cpu(i) {
> 		struct flow_cache_percpu *fcp =3D per_cpu_ptr(fc->percpu, i);
> 		kfree(fcp->hash_table);
> 		fcp->hash_table =3D NULL;
> 	}
>=20
> 	free_percpu(fc->percpu);
> 	fc->percpu =3D NULL;
> }
> EXPORT_SYMBOL(flow_cache_fini);
>=20
>=20
> Seems to solve both the freeze and the bug on restarting libvirtd/rtk=
it!
>=20

Thanks a lot for testing!

I'll submit the updated patch now.
