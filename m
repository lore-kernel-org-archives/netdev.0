From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Tue, 28 May 2013 17:34:53 -0700
Message-ID: <1369787693.3301.586.camel@edumazet-glaptop>
References: <519B8908.9080007@yandex-team.ru>
	  <1369150693.3301.233.camel@edumazet-glaptop>
	  <519BB90B.6080706@yandex-team.ru>
	  <1369188080.3301.268.camel@edumazet-glaptop>
	  <1369201765.3301.299.camel@edumazet-glaptop> <519CB2D8.103@yandex-team.ru>
	  <1369225837.3301.324.camel@edumazet-glaptop>
	  <519CC2FB.2010006@yandex-team.ru>
	  <20130522174532.GC3431@linux.vnet.ibm.com> <519D19DA.50400@yandex-team.ru>
	  <20130525113715.GA3795@linux.vnet.ibm.com>
	  <51A39E11.5020405@yandex-team.ru>
	 <1369699930.3301.494.camel@edumazet-glaptop>
	 <51A47496.6000100@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Dipankar Sarma <dipankar@in.ibm.com>,
	zhmurov@yandex-team.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Roman Gushchin <klamm@yandex-team.ru>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51A47496.6000100@yandex-team.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-28 at 13:10 +0400, Roman Gushchin wrote:
> On 28.05.2013 04:12, Eric Dumazet wrote:

> > Adding a barrier() is probably what we want.
>=20
> I agree, inserting barrier() is also a correct and working fix.

Yeah, but I can not find a clean way to put it inside the "for (;;)"

for (barrier();;)  ->

error: expected expression before =E2=80=98__asm__=E2=80=99

No user currently does :

if (condition)
	hlist_nulls_for_each_entry_rcu(tpos, pos, head, member)

But who knows...
