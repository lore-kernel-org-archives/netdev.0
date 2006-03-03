From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] powerpc: ibmveth: Harden driver initilisation for kexec
Date: Thu, 2 Mar 2006 20:12:42 -0800
Message-ID: <20060302201242.b688f811.rdunlap@xenotime.net>
References: <20060131041055.5623C68A46@ozlabs.org>
	<200603031122.51174.michael@ellerman.id.au>
	<20060302163423.f758c5bc.rdunlap@xenotime.net>
	<200603031210.53220.michael@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc64-dev@ozlabs.org, jgarzik@pobox.com, anton@samba.org,
	netdev@vger.kernel.org
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: michael@ellerman.id.au
In-Reply-To: <200603031210.53220.michael@ellerman.id.au>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, 3 Mar 2006 12:10:47 +1100 Michael Ellerman wrote:

> On Fri, 3 Mar 2006 11:34, Randy.Dunlap wrote:
> > On Fri, 3 Mar 2006 11:22:45 +1100 Michael Ellerman wrote:
> > > Hi Jeff,
> > >
> > > I realise it's late, but it'd be really good if you could send this up
> > > for 2.6.16, we're hosed without it.
> >
> > I'm wondering if this means that for every virtual/hypervisor
> > situation, we have to modify any $interested_drivers.
> > Why wouldn't we come up with a cleaner solution (in the long term)?
> >
> > E.g., could the hypervisor know when one of it's virtual OSes
> > dies or reboots and release its resources then?
> 
> It does exactly that for a regular reboot, but when we kexec we _don't_ die or 
> reboot, as far as the Hypervisor is concerned it's all systems go.
> 
> It's something of a double-edged sword, we're totally in control which gives 
> us lots of flexibility, and _fast_ reboot times, but we also have to do a bit 
> of extra stuff (ie. this patch) to keep things sane.

s/this patch/some patch/

Yes, you have certainly thought about this more/longer than I have,
so why is something more generic like this bad instead of good:

Somewhere early in start_kernel() (e.g.), do an hv call that says
"free all assigned resources".

Maybe hv doesn't know "all assigned resources."
Maybe it's just that this patch is simpler than an hv change,
although this (current) patch could leave some other drivers that
need to be "fixed," while an hv change wouldn't do that.

So I'm not opposed to this current patch as a short-term solution,
but I don't think it's the right long-term solution.

---
~Randy
