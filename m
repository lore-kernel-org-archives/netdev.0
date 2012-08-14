From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next v2 00/15] net: introduce upper device
 lists and remove dev->master
Date: Tue, 14 Aug 2012 21:32:53 +0100
Message-ID: <1344976373.2690.41.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
	<20120814201950.GA17781@quad.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, ursula.braun@de.ibm.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	shemminger@vyatta.com, sean.hefty@intel.com, therbert@google.com,
	roland@kernel.org, linux-s390@vger.kernel.org,
	linux-rdma@vger.kernel.org, fubar@us.ibm.com, fbl@redhat.com,
	hal.rosenstock@gmail.com, Jiri Pirko <jiri@resnulli.us>,
	faisal.latif@intel.com, blaschka@linux.vnet.ibm.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com,
	xiyou.wangcong@gmail.com, jitendra.kalsaria@qlogic.com,
	divy@chelsio.com, gregory.v.rose@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, joe@perches.com, linux390@de.ibm.com, davem@davemloft.net
To: Andy Gospodarek <gospo@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20120814201950.GA17781@quad.redhat.com>
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

On Tue, 2012-08-14 at 16:19 -0400, Andy Gospodarek wrote:
> On Tue, Aug 14, 2012 at 05:05:33PM +0200, Jiri Pirko wrote:
> > Hi all.
> > 
> > Recent discussion around
> > "[net-next] bonding: don't allow the master to become its slave"
> > forced me to think about upper<->lower device connections.
> > 
> > This patchset adds a possibility to record upper device linkage.
> > All upper<->lower devices are converted to use this mechanism right after.
> > That leads to dev->master removal because this info becomes redundant since
> > "unique links" have the same value.
> > 
> > After all changes, there is no longer possible to do:
> > "bond->someotherdevice->samebond"
> > 
> > Also I think that drivers like cxgb3, qlcnic, qeth would benefit by this
> > in future by being able to get more appropriate info about l3 addresses.
> > 
> > v1->v2:
> > - s/unique/master/ better naming + stays closer to the history
> > - fixed vlan err goto
> > - original patch 15 (WARN_ON change) is squashed into the first patch
> > - fixed netdev_unique_upper_dev_get_rcu() case of upper==NULL
> I just started to review v1 when v2 came out, but luckily the changes
> were not too significant that I need to start all over.
> 
> The first note is that I didn't like the use of the term 'upper' -- it
> seems like 'stacked' might be a better alternative as these are stacked
> devices.

When linking any two devices in a stack, one will be upper and the other
lower.  The lower device might itself be stacked on top of a further
device, so 'stacked' is not a useful distinguishing adjective in
variable names.  It might be a useful term in the commit messages and
kernel-doc, though.

> One thing to note is that I don't see any clear changelog that states
> the current goals for this.  You have stated in several places that it
> will no longer be possible to create bonds of bonds, but there are
> probably a few more things it might be wise to intentionally outlaw.
>
> What about teams of teams?  Or teams of bonds?  Or bonds of teams?
> Bonds of vlans?
[...]

It doesn't disallow bonds of bonds (unless I'm missing something).  It
disallows loops that involve any or all of those types of stacked
devices.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
