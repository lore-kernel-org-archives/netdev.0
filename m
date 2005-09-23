From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Fri, 23 Sep 2005 19:47:53 +0200
Message-ID: <43343FC9.5090601@cosmosbay.com>
References: <43308324.70403@cosmosbay.com> <200509221454.22923.ak@suse.de> <20050922125849.GA27413@infradead.org> <200509221505.05395.ak@suse.de> <Pine.LNX.4.62.0509220835310.16793@schroedinger.engr.sgi.com> <4332D2D9.7090802@cosmosbay.com> <20050923171120.GO731@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <clameter@engr.sgi.com>, Andi Kleen <ak@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750921AbVIWRsB@vger.kernel.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050923171120.GO731@sunbeam.de.gnumonks.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Harald Welte a =E9crit :
> On Thu, Sep 22, 2005 at 05:50:49PM +0200, Eric Dumazet wrote:
>=20
>>Christoph Lameter a =E9crit :
>>
>>>It should really be do_set_mempolicy instead to be cleaner. I got a =
patch here that fixes the=20
>>>policy layer.
>>>But still I agree with Christoph that a real vmalloc_node is better.=
 There will be no fuzzing=20
>>>around with memory policies etc and its certainly better performance=
 wise.
>>
>>vmalloc_node() should be seldom used, at driver init, or when a new
>>ip_tables is loaded. If it happens to be a performance problem, then
>>we can optimize it.  Why should we spend days of work for a function
>>that is yet to be used ?
>=20
>=20
> I see a contradiction in your sentence.  "a new ip_tables is loaded"
> every time a user changes a single rule.  There are numerous setups t=
hat
> dynamically change the ruleset (e.g. at interface up/down point, or e=
ven
> think of your typical wlan hotspot, where once a user is authorized,
> he'll get different rules.
>=20

But a user changing a single rule usually calls (fork()/exec()) a progr=
am=20
called iptables. The underlying cost of all this, plus copying the rule=
s to=20
user space, so that iptables change them and reload them in the kernel =
is far=20
more important than an hypothetical vmalloc_node() performance problem.

Eric
