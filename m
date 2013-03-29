From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add a synchronize_net() in
 netdev_rx_handler_unregister()
Date: Fri, 29 Mar 2013 15:39:39 -0400 (EDT)
Message-ID: <20130329.153939.1647102798438939425.davem@davemloft.net>
References: <20130329094856.GB1677@minipsycho.orion>
	<1364562082.5113.16.camel@edumazet-glaptop>
	<20130329192011.GO3320@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, jpirko@redhat.com, rostedt@goodmis.org,
	andy@greyhouse.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, nicolas.2p.debian@gmail.com,
	tglx@linutronix.de, streeter@redhat.com, stephen@networkplumber.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130329192011.GO3320@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 29 Mar 2013 12:20:11 -0700

> On Fri, Mar 29, 2013 at 06:01:22AM -0700, Eric Dumazet wrote:
>> [PATCH] net: add a synchronize_net() in netdev_rx_handler_unregister=
()
>>=20
>> commit 35d48903e97819 (bonding: fix rx_handler locking) added a race
>> in bonding driver, reported by Steven Rostedt who did a very good
>> diagnosis :
 ...
>> We can fix bug this in two ways. First is adding a test in
>> bond_handle_frame() and others to check if rx_handler_data is NULL.
>>=20
>> A second way is adding a synchronize_net() in
>> netdev_rx_handler_unregister() to make sure that a rcu protected rea=
der
>> has the guarantee to see a non NULL rx_handler_data.
>>=20
>> The second way is better as it avoids an extra test in fast path.
>>=20
>> Reported-by: Steven Rostedt <rostedt@goodmis.org>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Jiri Pirko <jpirko@redhat.com>
>> Cc: Paul E. McKenney <paulmck@us.ibm.com>
>=20
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>=20
> With kudos to Steven Rostedt for his analogy between RCU and
> Schr=F6dinger's cat.  ;-)

Applied and queued up for -stable, thanks Everyone.
