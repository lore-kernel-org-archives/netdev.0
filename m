From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/7] bridge: Add addresses from static fdbs to
 bridge address list
Date: Thu, 27 Feb 2014 09:53:36 +0200
Message-ID: <20140227075336.GF16484@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
	<1393427905-6811-4-git-send-email-vyasevic@redhat.com>
	<20140226085707.55bdab94@nehalam.linuxnetplumber.net>
	<530E25CC.6010705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com,
	Stephen Hemminger <stephen@networkplumber.org>, shemminger@vyatta.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <530E25CC.6010705@redhat.com>
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

On Wed, Feb 26, 2014 at 12:35:08PM -0500, Vlad Yasevich wrote:
> On 02/26/2014 11:57 AM, Stephen Hemminger wrote:
> > On Wed, 26 Feb 2014 10:18:21 -0500
> > Vlad Yasevich <vyasevic@redhat.com> wrote:
> > 
> >> When a static fdb entry is created, add the mac address to the bridge
> >> address list.  This list is used to program the proper port's
> >> address list.
> >>
> >> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> > 
> > I don't like this level of bookkeeping it starts to mix
> > layers between the bridge network interface as entity for talking to the
> > local host, and forwarding table entries.
> 
> Actually this is one of the reasons this isn't done through the
> br->dev->uc.  Forwarding table entries are still per-port.
> 
> > 
> > Many times static entries are used as alternative to flooding in
> > environments which don't trust STP.
> 
> Ok, and how would this be problematic?  If one wants to turn off
> promisc in this environment, then receive filters needs to be properly
> programmed.
> 
> > 
> > Plus, it looks like another major source of bugs.
> > 
> 
> Any new code is a potential source of issues.  Are you saying
> No to any new code in bridge?
> 
> -vlad

I'm guessing Stephen merely worries about
multiple data structures that need to stay in
sync, and asks that you revisit
using private hw address list in the bridge.

What's the issue with walking fdb exactly?
You say
 1)  I tried using the fdb table itself as main repository, but
      this caused difficulties in synchronizing this table with
      the interface filters later on.

I'm guessing you refer to writing addresses out to ports
directly when walking the hash being impossible
since this datastructure uses rcu and spinlocks?
Fair enough but the entries you care about
seem to only be modified under RTNL so just
copy them out to a temporary list.
This might be less efficient, but will be simpler I think.

-- 
MST
