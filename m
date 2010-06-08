From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.35-rc2-git1 - net/mac80211/sta_info.c:125 invoked
 rcu_dereference_check() without protection!
Date: Tue, 8 Jun 2010 09:26:01 -0700
Message-ID: <20100608162601.GC2397@linux.vnet.ibm.com>
References: <AANLkTintKf_9C1sBsUac6Prvb1nWn7nWszatJ8yUb-VM@mail.gmail.com>
 <20100607235941.GD2387@linux.vnet.ibm.com>
 <1275981969.3706.1.camel@jlt3.sipsolutions.net>
 <AANLkTillxWXGO4nIqb6hdbaw4P40WLHEPpy_GiM_hSW-@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTillxWXGO4nIqb6hdbaw4P40WLHEPpy_GiM_hSW-@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 08, 2010 at 07:29:48AM -0400, Miles Lane wrote:
> On Tue, Jun 8, 2010 at 3:26 AM, Johannes Berg <johannes@sipsolutions.=
net> wrote:
> > On Mon, 2010-06-07 at 16:59 -0700, Paul E. McKenney wrote:
> >> On Mon, Jun 07, 2010 at 02:25:44PM -0400, Miles Lane wrote:
> >> > [ =A0 43.478812] [ INFO: suspicious rcu_dereference_check() usag=
e. ]
> >> > [ =A0 43.478815] -----------------------------------------------=
----
> >> > [ =A0 43.478820] net/mac80211/sta_info.c:125 invoked
> >> > rcu_dereference_check() without protection!
> >> > [ =A0 43.478824]
> >> > [ =A0 43.478824] other info that might help us debug this:
> >> > [ =A0 43.478826]
> >> > [ =A0 43.478829]
> >> > [ =A0 43.478830] rcu_scheduler_active =3D 1, debug_locks =3D 1
> >> > [ =A0 43.478834] no locks held by NetworkManager/4017.
> >>
> >> Hmmm... =A0Johannes's update has been merged, and it requires that=
 callers
> >> either be in an RCU read-side critical section or hold either the
> >> ->sta_lock or the ->sta_mtx, and this thread does none of this.
> >>
> >> Johannes, any thoughts?
> >>
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Thanx, Paul
> >>
> >> > [ =A0 43.478837] stack backtrace:
> >> > [ =A0 43.478842] Pid: 4017, comm: NetworkManager Not tainted 2.6=
=2E35-rc2-git1 #8
> >> > [ =A0 43.478846] Call Trace:
> >> > [ =A0 43.478849] =A0<IRQ> =A0[<ffffffff81064e9c>] lockdep_rcu_de=
reference+0x9d/0xa5
> >> > [ =A0 43.478876] =A0[<ffffffffa010cb3c>] sta_info_get_bss+0x71/0=
x12d [mac80211]
> >> > [ =A0 43.478889] =A0[<ffffffffa010cc0d>] ieee80211_find_sta+0x15=
/0x2f [mac80211]
> >> > [ =A0 43.478902] =A0[<ffffffffa019ae16>] iwlagn_tx_queue_reclaim=
+0xe7/0x1bb [iwlagn]
> >
> > iwlwifi wasn't using rcu protection here -- already sent a patch fi=
xing
> > it. My mistake, I =A0think. Thanks for checking :)
> >
> > johannes
>=20
> Yes, your patch works for me.

Thank you both!!!

							Thanx, Paul
