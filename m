From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH v4 4/9] rdma/cm: Update port reservation to support AF_IB
Date: Wed, 13 Feb 2013 17:44:58 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237368B9A40F@ORSMSX101.amr.corp.intel.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
 <1358891797-14625-5-git-send-email-sean.hefty@intel.com>
 <511B7474.3040201@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <511B7474.3040201-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > The AF_IB uses a 64-bit service id (SID), which the
> > user can control through the use of a mask.  The rdma_cm
> > will assign values to the unmasked portions of the SID
> > based on the selected port space and port number.
> 
> Something here I am not sure to follow -- if AF_IB consumers are allowed
> to provide 64-bit SID, how
> the IB port space is expressed in their SIDs?

The spec, notably the RDMA CM Annex, provides fixed values for the upper 48-bits of the service ID.  Only the lower 16-bits are available to users.  The upper bits end up identifying the various 'port spaces'. 

(Note that there's no actual association between an IB port space and port spaces in the IP network stack.)

> Wouldn't it make sense to use a simpler approach that has a dedicated
> IB_PS in the port space
> portion of the RDMA-CM IP IBTA annex and let the consumer provide 16
> bits for their part of the SID?

Ultimately, IB establishes communication using 64-bit service IDs, which is what sockaddr_ib exposes.

The SID mask was proposed by Jason as a way to simplify things.  Conceptually, AF_IB has a single port space range, the 64-bit SID.  The mask helps us break the SID into the various ranges, so we can clearly know which parts of the SID are fixed, and which can be variable.  E.g. when connecting, the entire SID must be provided.  However, when binding we want to support binding to a specific SID or only to a SID range (i.e. port space).

(I'm having trouble finding the original email threads where this was discussed.)

- Sean
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
