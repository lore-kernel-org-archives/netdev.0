From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Thu, 7 Aug 2008 11:45:01 -0700
Message-ID: <200808071145.03848.divy@chelsio.com>
References: <200807300019.m6U0JkdY012558@localhost.localdomain> <aday73jxdfs.fsf@cisco.com> <200807311752.00911.divy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, "Karen Xie" <kxie@chelsio.com>,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	davem@davemloft.net, michaelc@cs.wisc.edu,
	"Steve Wise" <swise@opengridcomputing.com>, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com,
	"Dimitrios Michailidis" <dm@chelsio.com>,
	"Casey Leedom" <leedom@chelsio.com>,
	"linux-scsi" <linux-scsi@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <200807311752.00911.divy@chelsio.com>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 31 July 2008 05:51:59 pm Divy Le Ray wrote:
> On Wednesday 30 July 2008 02:35:51 pm Roland Dreier wrote:
> >  > * From a networking standpoint, our main concern becomes how this
> >  > interacts with the networking stack.  In particular, I'm concerned
> >  > based on reading the source that this driver uses "TCP port stealing"
> >  > rather than using a totally separate MAC address (and IP).
> >  >
> >  > Stealing a TCP port on an IP/interface already assigned is a common
> >  > solution in this space, but also a flawed one.  Precisely because the
> >  > kernel and applications are unaware of this "special, magic TCP port"
> >  > you open the potential for application problems that are very
> >  > difficult for an admin to diagnose based on observed behavior.
> >
> > That's true, but using a separate MAC and IP opens up a bunch of other
> > operational problems.  I don't think the right answer for iSCSI offload
> > is clear yet.
> >
> >  - R.
>
> Hi Jeff,
>
> We've considered the approach of having a separate IP/MAC addresses to
> manage iSCSI connections. In such a context, the stack would have to be
> unaware of this iSCSI specific IP address. The iSCSI driver would then have
> to implement at least its own ARP reply mechanism. DHCP too would have to
> be managed separately. Most network setting/monitoring tools would also be
> unavailable.
>
> The open-iscsi initiator is not a huge consumer of TCP connections,
> allocating a TCP port from the stack would be reasonable in terms of
> resources in this context. It is however unclear if it is an acceptable
> approach.
>
> Our current implementation was designed to be the most tolerable one
> within the constraints - real or expected - aforementioned.
>

Hi Jeff,

Mike Christie will not merge this code until he has an explicit 
acknowledgement from netdev.

As you mentioned, the port stealing approach we've taken has its issues.
We consequently analyzed your suggestion to use a different IP/MAC address for 
iSCSI and it raises other tough issues (separate ARP and DHCP management, 
unavailability of common networking tools).
On these grounds, we believe our current approach is the most tolerable.
Would the stack provide a TCP port allocation service, we'd be glad to use it 
to solve the current concerns.
The cxgb3i driver is up and running here, its merge is pending our decision.

Cheers,
Divy
