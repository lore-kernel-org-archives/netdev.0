From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] Fix repeatable Oops on container destroy with conntrack
Date: Wed, 28 Sep 2011 23:08:51 +0200
Message-ID: <20110928210851.GA2761@1984>
References: <2184C0CE5A5EDC94CDDA5053@Ximines.local>
 <20110912072524.GA2996@p183.telecom.by>
 <20110912093749.GE2194@1984>
 <E0902A9541FD5D118EA02B31@Ximines.local>
 <20110912183357.GC3641@1984>
 <87A32B21CA99D62CE1AB7A4B@Ximines.local>
 <7631498AC7E7C0EAD641AC7D@nimrod.local>
 <20110914013500.GB17051@1984>
 <A51A04647674405AF6C39A4F@nimrod.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <A51A04647674405AF6C39A4F@nimrod.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2011 at 09:01:34AM +0100, Alex Bligh wrote:
> --On 14 September 2011 03:35:00 +0200 Pablo Neira Ayuso
> <pablo@netfilter.org> wrote:
> 
> >>Is this new version OK? I am happy to adjust if not.
> >
> >Hm, I still think that this is a workaround.
> 
> It is a bit of a workaround, that is true. But it is a workaround
> that will fix the bug in every kernel since 2.6.32 (and perhaps
> before - I haven't looked). It's thus reasonably easily applicable
> to stable kernel series.

The container support for netfilter seems to be in intermediate state,
we need several patches to get it finished that:

* subsys_table definition in nfnetlink.c.
* ctnl_notifier and ctnl_notifier_exp definitions in
  nfnetlink_conntrack.c
* similar things for nfnetlink_queue and nfnetlink_log.

If nobody is going to fix all these, I'll find some spare time to do
it myself, but I don't think we'll have a proper fix that we can pass
to -stable. This will have to go to net-next, given the amount of
patches that we'll need to appropriately fix this.

> I'm not clued-up enough on Netfilter to know what the right fix is,
> but is applying the workaround in a commit which could be easily
> backported, then applying the 'right fix' (assuming that is different)
> a reasonable strategy?
> 
> As you can probably tell, my interest here is to get something that
> doesn't oops into stable kernels.

As said, I'm not sure that this can happen, given that the amount of
patches that we need to fix it fine, sorry.
