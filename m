From: James Lentini <jlentini@netapp.com>
Subject: Re: Re: [iproute2] IPoIB link layer address bug
Date: Thu, 23 Mar 2006 12:12:52 -0500 (EST)
Message-ID: <Pine.LNX.4.61.0603231155401.23670@jlentini-linux.nane.netapp.com>
References: <Pine.LNX.4.61.0603161707360.23670@jlentini-linux.nane.netapp.com>
	<20060321155617.3ae419b2@localhost.localdomain>
	<20060322013046.GA29127@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	openib-general <openib-general@openib.org>
Return-path: <openib-general-bounces@openib.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060322013046.GA29127@obsidianresearch.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


On Tue, 21 Mar 2006, Jason Gunthorpe wrote:

> On Tue, Mar 21, 2006 at 03:56:17PM -0800, Stephen Hemminger wrote:
> 
> > Okay, but there are number of other places in iproute2 that call 
> > ll_addr_a2n() with ifr.ifr_hwaddr.sa_data. And that is 14 bytes.  
> > If you want to fix those it will be harder since it would increase 
> > the sizeof(struct sockaddr) and potentially break compatibility.
> 
> Maybe the best thing is to upgrade ip (and or netlink?) to use 
> netlink messages instead of ioctls for the remaining problematic 
> operations. Since netlink already supports an arbitary length hwaddr 
> there should be no compatability problem.
> 
> Just browsing I see usages of SIOCSIFHWBROADCAST, SIOCSIFHWADDR, 
> SIOCADDMULTI, SIOCDELMULTI and SIOCGIFHWADDR that use a struct 
> ifreq..
> 
> I know SIOCGIFHWADDR can be done over netlink, but I'm not too 
> familiar with the others..

Making ip neighbor work with IPoIB address is what I'm interested in 
now.

As you and Jason point out there are a lot of places where ifreqs are 
used and hence options that will not support IPoIB addresses.

Do you agree with Jason's strategy of moving the ioctls to netlink 
messages (if netlink analogs exist)?
