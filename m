From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH] Don't allow multiple TPGs or targets to share a portal
Date: Mon, 18 Feb 2013 20:34:30 -0800
Message-ID: <1361248470.20523.31.camel@haakon2.linux-iscsi.org>
References: <1360364708-26104-1-git-send-email-agrover@redhat.com>
	 <1360787516.13707.59.camel@haakon2.linux-iscsi.org>
	 <511C0EFD.9060702@redhat.com>
	 <1360943188.13707.114.camel@haakon2.linux-iscsi.org>
	 <5122AE05.7060707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org
To: Andy Grover <agrover@redhat.com>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <5122AE05.7060707@redhat.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-02-18 at 14:41 -0800, Andy Grover wrote:
> On 02/15/2013 07:46 AM, Nicholas A. Bellinger wrote:
> > The wording in section Section 3.4.1, e) that your referring to:
> >
> > "Each Network Portal, as utilized by a given iSCSI Node, belongs to
> > exactly one portal group within that node."
> >
> > does not mean that individual network portals are limited to a single
> > network entity, but that network portals are linked to a single TPG
> > within an individual TargetName.  Eg, 'that node' does not mean the
> > entire physical machine (network entity), that may contain multiple
> > nodes (TargetName+TargetPortalGroupTag endpoints).
> >
> > However, in practice I've not yet seen a target implementation that
> > supports multiple TPGs actually enforce this, considering this is not
> > accompanied by a "SHOULD not" or "MUST not" anywhere in the spec.  So
> > unless you have a specific problem case where this is causing an issue
> > with an initiator, I'm likely not going to accept a kernel patch to
> > change existing behavior.
> 
> OK, so I'm clear now that a NetworkPortal can be shared among 
> TargetNames, but not among TPGs within a TargetName.
> 
> But LIO currently allows it.
> See https://bugzilla.redhat.com/show_bug.cgi?id=908368 .
> 
> The tester's actual issue may not be related to this area, but if you 
> look at the attachment in comment 2, this configuration was allowed.
> 

Yes, it's related.  He will want to be using multiple IQNs for this type
of setup.

> I don't think this is an issue where we need to worry about existing 
> behavior. This *can't* work because the initiator passes the desired 
> TargetName during iSCSI login, but not TargetPortalGroupTag. There's no 
> way a target can tell which TPG the initiator wants if the TargetName 
> for two are the same.
> 
> We could add a check for this to the rtslib userspace library, but this 
> would mean the kernel could still be configured this way, if rtslib was 
> not used to wrap configfs accesses. Therefore I'd push for the kernel to 
> check for this. Would a patch for that fly?
> 

So considering in this special case that an target cannot distinguish
between TargetPortalGroup for an incoming Login Request, enforcing from
the kernel that individual network portals only be mapped to a single
TargetPortalGroup within TargetName context is going to be the proper
resolution here.

I'm working on a patch for this, and will post shortly..

Thanks,

--nab
