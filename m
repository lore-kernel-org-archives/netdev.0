From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 4/4] kthread: use kthread_create_on_cpu()
Date: Tue, 30 Nov 2010 10:59:01 +0100
Message-ID: <1291111141.2904.17.camel@edumazet-laptop>
References: <1291043719.3435.981.camel@edumazet-laptop>
	 <1290972833.29196.90.camel@edumazet-laptop>
	 <20101128224024.GA12300@basil.fritz.box>
	 <1290984712.29196.100.camel@edumazet-laptop>
	 <20101128230146.GB12300@basil.fritz.box>
	 <1290987424.29196.128.camel@edumazet-laptop>
	 <20101129090510.GA15763@basil.fritz.box>
	 <1291023532.3435.29.camel@edumazet-laptop>   <15903.1291109892@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-arch@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <15903.1291109892@redhat.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 30 novembre 2010 =C3=A0 09:38 +0000, David Howells a =C3=A9cri=
t :
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > +		p =3D kthread_create_on_cpu(run_ksoftirqd, hcpu, hotcpu,
> > +					  "ksoftirqd/%d", hotcpu);
>=20
> Does kthread_create_on_cpu() need to take hotcpu twice?  Can one of t=
he
> arguments be folded into the other?
>=20
> David

The second one is used in a printf() like to build a string, its not
really part of the API..

Caller could do instead :

char name[32];
sprintf(name, "ksoftirqd/%d", whatever_id);
p =3D kthread_create_on_cpu(run_ksoftirqd, hcpu, hotcpu, name);
