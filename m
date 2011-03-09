From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch V2] bonding: fix netpoll in active-backup mode
Date: Wed, 09 Mar 2011 20:32:31 +0800
Message-ID: <4D77735F.30908@redhat.com>
References: <1299578336-5888-1-git-send-email-amwang@redhat.com> <20110308134348.GB19072@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110308134348.GB19072@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2011=E5=B9=B403=E6=9C=8808=E6=97=A5 21:43, Neil Horman =E5=86=
=99=E9=81=93:
> On Tue, Mar 08, 2011 at 05:58:56PM +0800, Amerigo Wang wrote:
>> V2: avoid calling slave_diable_netpoll() with write_lock_bh() held.
>>
>> netconsole doesn't work in active-backup mode, because we don't do a=
nything
>> for nic failover in active-backup mode. We should disable netpoll on=
 the
>> failing slave when it is detected down and enable netpoll when it be=
comes
>> the active slave.
>>
> You still haven't explained why it needs to be this way.  what exactl=
y is the
> shortcomming with leaving netpoll enabled on all slaves, regardless o=
f state?
> It should be sufficient if, during a failover in a mode where the ina=
ctive slave
> should not tx data, that you simply clear the slave __LINK_STATE_STAR=
T bit.  That will
> prevent higher layers from sending any queued data without you needin=
g to muck
> about with netpoll state.
>

Oh, actually I thought the struct net_device of the failing interface w=
ill be freed,
but that is not true...

So, yeah, I think just setup netpoll in bond_netpoll_setup() should be =
sufficient.

Thanks.
