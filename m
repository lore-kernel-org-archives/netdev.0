From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next v2 01/15] net: introduce upper device
	lists
Date: Tue, 14 Aug 2012 16:00:55 -0700
Message-ID: <20120814160055.1e948456@nehalam.linuxnetplumber.net>
References: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
	<1344956748-2099-2-git-send-email-jiri@resnulli.us>
	<1344983624.2690.77.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, ursula.braun@de.ibm.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	sean.hefty@intel.com, therbert@google.com, roland@kernel.org,
	linux-s390@vger.kernel.org, linux-rdma@vger.kernel.org,
	fubar@us.ibm.com, fbl@redhat.com, hal.rosenstock@gmail.com,
	Jiri Pirko <jiri@resnulli.us>, faisal.latif@intel.com,
	linux-driver@qlogic.com, blaschka@linux.vnet.ibm.com,
	sony.chacko@qlogic.com, gregory.v.rose@intel.com,
	xiyou.wangcong@gmail.com, jitendra.kalsaria@qlogic.com,
	divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net, joe@perches.com,
	linux390@de.ibm.com, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1344983624.2690.77.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Aug 2012 23:33:44 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Tue, 2012-08-14 at 17:05 +0200, Jiri Pirko wrote:
> > This lists are supposed to serve for storing pointers to all upper devices.
> > Eventually it will replace dev->master pointer which is used for
> > bonding, bridge, team but it cannot be used for vlan, macvlan where
> > there might be multiple upper present. In case the upper link is
> > replacement for dev->master, it is marked with "master" flag.
> 
> Something I found interesting is that the dev->master pointer and now
> netdev_master_upper_dev_get{,_rcu}() are hardly used by the stackled
> drivers that set the master.  They also have to set an rx_handler on the
> lower device (which is itself mutually exclusive) which gets its own
> context pointer (rx_handler_data).
> 
> Instead, the master pointer is mostly used by device drivers to find out
> about a bridge or bonding device above *their* devices.  And that seems
> to work only for those specific device drivers, not e.g. openvswitch or
> team.  I wonder if we could find a better way to encapsulate the things
> they want do do, in a later step (not holding up this change!).

The concept is master is very useful to user level config things like
Vyatta for seeing parent/child relationship. Since is in ABI now, it
must stay.
