From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Patch] bonding: fix potential deadlock in bond_uninit()
Date: Wed, 31 Mar 2010 16:02:37 -0700
Message-ID: <20100331160237.73560dfe@s6510>
References: <20100331105559.5607.38643.sendpatchset@localhost.localdomain>
	<m1d3ykzq5a.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1d3ykzq5a.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Mar 2010 04:28:33 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Amerigo Wang <amwang@redhat.com> writes:
> 
> > bond_uninit() is invoked with rtnl_lock held, when it does destroy_workqueue()
> > which will potentially flush all works in this workqueue, if we hold rtnl_lock
> > again in the work function, it will deadlock.
> >
> > So unlock rtnl_lock before calling destroy_workqueue().
> 
> Ouch.  That seems rather rude to our caller, and likely very
> dangerous.
> 
> Is this a deadlock you actually hit, or is this something lockdep
> warned about?
> 
> My gut feel says we need to move the destroy_workqueue into
> the network device destructor.
> 
> Eric

Why is there one workqueue per bond device rather than just one workqueue for
all bonding devices controlled by the module instance? It would be cleaner
on removal and less space and overhead.  I can't see that doing arp/mii or alb
work is high parallel and load activity.
