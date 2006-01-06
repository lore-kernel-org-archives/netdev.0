From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 06 Jan 2006 15:00:17 +0100
Message-ID: <43BE77F1.4090301@cosmosbay.com>
References: <20060105235845.967478000@sorel.sous-sol.org>	 <20060106004555.GD25207@sorel.sous-sol.org>	 <Pine.LNX.4.64.0601051727070.3169@g5.osdl.org>	 <43BE43B6.3010105@cosmosbay.com> <1136554632.30498.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932430AbWAFOBE@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1136554632.30498.7.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox a =E9crit :
> On Gwe, 2006-01-06 at 11:17 +0100, Eric Dumazet wrote:
>> I assume that if a CPU queued 10.000 items in its RCU queue, then th=
e oldest=20
>> entry cannot still be in use by another CPU. This might sounds as a =
violation=20
>> of RCU rules, (I'm not an RCU expert) but seems quite reasonable.
>=20
> Fixing the real problem in the routing code would be the real fix.=20
>=20

So far nobody succeeded in 'fixing the routing code', few people can ev=
en read=20
the code from the first line to the last one...

I think this code is not buggy, it only makes general RCU assumptions a=
bout=20
delayed freeing of dst entries. In some cases, the general assumptions =
are=20
just wrong. We can fix it at RCU level, and future users of call_rcu_bh=
() wont=20
have to think *hard* about 'general assumptions'.

Of course, we can ignore the RCU problem and mark somewhere on a sticke=
r:=20
***DONT USE OR RISK CRASHES***
***USE IT ONLY FOR FUN***

> The underlying problem of RCU and memory usage could be solved more
> safely by making sure that the sleeping memory allocator path always
> waits until at least one RCU cleanup has occurred after it fails an
> allocation before it starts trying harder. That ought to also natural=
ly
> throttle memory consumers more in the situation which is the right
> behaviour.
>=20

In the case of call_rcu_bh(), you can be sure that the caller cannot af=
ford=20
'sleeping memory allocations'. Better drop a frame than block the stack=
, no ?

Eric
