From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.4/2.6] ipvs: improve conn rehashing, other fixes
Date: Tue, 23 Mar 2004 10:34:54 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403231027420.1157@u.domain.uli>
References: <20040321230703.408d2240.davem@redhat.com>
 <Pine.LNX.4.44.0403230036130.3318-600000@penguin.linux-vs.org>
 <20040322183641.68ecb8a3.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Wensong Zhang <wensong@linux-vs.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040322183641.68ecb8a3.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 22 Mar 2004, David S. Miller wrote:

> On Tue, 23 Mar 2004 00:58:38 +0800 (CST)
> Wensong Zhang <wensong@linux-vs.org> wrote:
>
> > Dave, please check the attached patches. There are three patches for 2.4,
> > and two for 2.6.
>
> I am going to apply everything except the ip_vs_ctl.c change as
> Julian has tol me under seperate cover that the locking he adds
> there is not really necessary.

	It was the old version. Please, apply everything sent from
Wensong. The old versions protect only the list which is not needed
on edit but the new versions from Wensong ensure that the service is
updated safely while there are no other CPUs using the schedulers.
By this way, after my last posting, we fix missing locking in the
following schedulers: WRR, RR, SH, DH. Now the benefit is that we
do not add locking in the fast path, instead, we add it only on
edit (slow path).

Regards

--
Julian Anastasov <ja@ssi.bg>
