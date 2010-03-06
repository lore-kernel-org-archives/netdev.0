From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Problems with remote-wakeup settings
Date: Sat, 6 Mar 2010 22:25:09 +0100
Message-ID: <201003062225.09514.rjw@sisk.pl>
References: <Pine.LNX.4.44L0.1003061601520.23895-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, USB list <linux-usb@vger.kernel.org>,
        linux-hotplug@vger.kernel.org,
        Kernel development list <linux-kernel@vger.kernel.org>,
        linux-input@vger.kernel.org,
        Linux-pm mailing list <linux-pm@lists.linux-foundation.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <Pine.LNX.4.44L0.1003061601520.23895-100000@netrider.rowland.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Saturday 06 March 2010, Alan Stern wrote:
> On Sat, 6 Mar 2010, Rafael J. Wysocki wrote:
> 
> > > It's not difficult in theory to tie together the WoL setting and the
> > > wakeup flag:
> > > 
> > > 	If ethtool changes the WoL setting, the driver's ioctl handler
> > > 	should make the corresponding change to the wakeup flag.
> > > 
> > > 	If ethtool queries the WoL setting, the ioctl handler should
> > > 	check the wakeup flag.  If the flag is off, it should report 
> > > 	that WoL is disabled; if the flag is on, it should report that 
> > > 	WoL is enabled.  (The same check should be made in the suspend
> > > 	routine.)
> > 
> > That's done this way already in all drivers I know, but we need a hook
> > from wake_store() back to the driver.
> 
> What for?  wake_store() can't be called during a sleep transition
> (because tasks are frozen) or while the system is asleep.  And if it is
> called at any other time, the driver doesn't need to know until either
> its ioctl handler or its suspend method runs.

Right.

That means, though, that the network adapter drivers' "get WoL" routines
should check should_wakeup too.  They don't do that right now, but IMO it's
reasonable to request that they be modified.

Adding netdev to the Cc list.

Rafael
