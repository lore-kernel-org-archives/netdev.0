From: dann frazier <dannf@hp.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 6 Nov 2009 16:17:16 -0700
Message-ID: <20091106231716.GJ29251@ldl.fc.hp.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com>
 <20091016152053.GA9862@ldl.fc.hp.com>
 <1255707193.2869.12.camel@achroite>
 <20091016214024.GA10091@ldl.fc.hp.com>
 <EDA0A4495861324DA2618B4C45DCB3EE5895AF@blrx3m08.blr.amer.dell.com>
 <4ADC906E.2050909@kadzban.is-a-geek.net>
 <EDA0A4495861324DA2618B4C45DCB3EE5896D2@blrx3m08.blr.amer.dell.com>
 <20091106084921.GA16700@bongo.bofh.it>
 <20091106220637.GB15533@mock.linuxdev.us.dell.com>
 <20091106223524.GA27121@bongo.bofh.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Matt Domsch <Matt_Domsch@Dell.com>, Narendra_K@Dell.com,
	bryan@kadzban.is-a-geek.net, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Jordan_Hargrave
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091106223524.GA27121@bongo.bofh.it>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 06, 2009 at 11:35:24PM +0100, Marco d'Itri wrote:
> On Nov 06, Matt Domsch <Matt_Domsch@Dell.com> wrote:
> 
> > > As a distribution developer I highly value solutions like this which do
> > > not require patching every application which deals with interface names
> > > and then teaching users about aliases which only work in some places and
> > > are unknown to the kernel.
> > Fair enough - but would you object if we changed the naming scheme
> > from eth%d to something else?
> I suppose that this would depend on what else. :-)
> Since you want radical changes I recommend that you design the new
> persistent naming infrastructure in a way that will allow root to choose
> to use the classic naming scheme, or many users will scream a lot and at
> least some distributions will do it anyway.
> I also expect that providing choice at the beginning of development may
> lead to more acceptance later if and when the new scheme will have
> proved itself to be superior (at least in some situations).
> You have tought about this for a long time and if so far you have not
> found a solution which is widely considered superior then I doubt that
> one will appear soon. Providing your favourite naming scheme as an
> optional add on will immediately benefit those who like it and greatly
> reduce opposition from those who do not.

This seems to me like a good installer feature - give the user an
option to enter a name for an interface, with the default option
to use the eth* names. To illustrate by example, I imagine an
installer flow that looks like this:

 [Do Hardware Discovery]
 [Automatically reorder kernel names for reasonable defaults;
  eth0-eth{n-1} map to n onboard nics]

  Sample user interface for network configuration:

 ------------Choose an interface to configure --------------
 | Multiple unconfigured interfaces detected.              |
 | Select an interface to configure by:                    |
 |   1. Kernel name (eth0, eth1, etc)                      |
 |   2. Mac Address                                        |
 |   3. Chassis name                                       |
 |   4. PCI Slot                                           |
 -----------------------------------------------------------

 ----Choose an interface to configure (by chassis name)-----
 |   1. LOM0                                               |
 |   2. LOM1                                               |
 |   3. Undefined                                          |
 |   4. Undefined                                          |
 -----------------------------------------------------------

 ----------------Name interface - (chassis name LOM0)-------
 |   Name to use for this interface [eth0]: __mynet0_      |
 -----------------------------------------------------------

 -----------------------------------------------------------
 | Configure interface - mynet0                            |
 |   1. DHCP                                               |
 |   2. Static                                             |
 |   ...                                                   |
 -----------------------------------------------------------
 
[Generate udev rules that bind the user-selected name to
 the user-selected attribute]
