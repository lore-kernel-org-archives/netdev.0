From: Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
Subject: Re:
Date: Mon, 27 Sep 2010 13:54:36 -0700
Message-ID: <4CA1048C.8020508@rincon.com>
References: <20100927200500.GB25879@obsidianresearch.com> <OF056C7E7C.A9A5EFC7-ON882577AB.006E6B89-882577AB.006F2C1E@us.ibm.com> <alpine.DEB.2.00.1009271521510.14117@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009271521510.14117-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/27/10 13:23, Christoph Lameter wrote:
> On Mon, 27 Sep 2010, David Stevens wrote:
>
>>          Because a querier can set the robustness value and
>> query interval to anything you want. In the original report,
>> he's not running a querier. The fact that it's a new group
>> doesn't matter -- these are per-interface.
>
> The per interface settings are used to force an IGMP version overriding
> any information by the queriers. You would not want to enable that because
> it disables support for other IGMP versions. Without the override
> different version of IGMP can be handled per MC group.
>
If a network vlan has IGMPv3 capability, then it should be able
to support both v2 and v3 Joins (clients).  But if the vlan is
IGMPv2 only, then an initial Join from a Linux client might go out
as v3 (if it hasn't seen a query yet) and be ignored.  I believe
this is the case that force_igmp_version really addresses.

And it turns out that  force_igmp_version=2 doesn't fully work.
If the host sees a IGMPv3 query, it still responds with a v3 Join
despite the flag.  Bug report and candidate patch here:
https://bugzilla.kernel.org/show_bug.cgi?id=18212
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
