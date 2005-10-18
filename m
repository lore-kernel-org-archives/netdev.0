From: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Subject: Re: Re: [PATCH] ebtables: Port ebt_[u]log.c to
	nf[netlink]_log
Date: Tue, 18 Oct 2005 15:12:17 +0000
Message-ID: <1129648337.4504.3.camel@localhost.localdomain>
References: <20051007234903.GR4450@rama.customers.eurospot.com>
	 <1129571999.3383.6.camel@localhost.localdomain>
	 <20051018085853.GG20338@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
In-Reply-To: <20051018085853.GG20338-XKR8MNpNCaUy1wpV0ib6OjPN8QKu1tr+@public.gmane.org>
Sender: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ebtables-devel>
List-Id: netdev.vger.kernel.org

Op di, 18-10-2005 te 10:58 +0200, schreef Harald Welte:
> On Mon, Oct 17, 2005 at 05:59:59PM +0000, Bart De Schuymer wrote:
> > Op za, 08-10-2005 te 01:49 +0200, schreef Harald Welte:
> > > Hi Bart!
> > > 
> > > The patch below is totally untested (though it compiles), and updates
> > > ebtables to resemble the behaviour that we now have in ipv4 (and ipv6):
> > > {ip,ip6,eb}tables just tell the nf_log core that they want to log a
> > > packet, the mechanism (syslog, nfnetlink_log, ...) is actually decided
> > > by nf_log.
> > > 
> > > By default, everything will behave like before.
> > > 
> > > Please review, and test that ebt_log and ebt_ulog are still working as
> > > expected.  Thanks!
> > 
> > Sorry for the late reply, some hardware problems got in the way.
> 
> no problem, I probably hold the record of delayed responses, so I can
> understand that completely ;)
> 
> > Apart from the comments below, the patch is fine by me (I tested both).
> 
> great.
> 
> > > +	nf_log_packet(PF_BRIDGE, hooknr, skb, in, out, &li, info->prefix);
> > 
> > Should be ebt_log_packet
> 
> why is that?  nf_log_packet() is a function provided by the netfilter
> core in net/netfilter/.  Do you want an ebt_log_packet() wrapper function that just calls
> nf_log_packet() ?

I see it works with nf_log_packet() too. I just tried to mimic what
you're doing for ebt_ulog... Anyway, I'll accept your judgement on this.

> > >  {
> > > -	return ebt_register_watcher(&log);
> > > +	int ret;
> > > +
> > > +	ret = ebt_register_watcher(&log);
> > > +	if (ret < 0)
> > > +		return ret;
> > > +	if (nf_log_register(PF_BRIDGE, &ebt_log_logger) < 0) {
> > > +		printk(KERN_WARNING "ebt_log: not logging via system console "
> > > +		       "since somebody else already registered for PF_INET\n");
> > > +		/* wecannot make module load fail here, since otherwise 
> > > +		 * ebtables userspace would abort */
> > > +	}
> > 
> > Since we're using PF_BRIDGE instead of PF_INET now, this if construct
> > can be replaced by a simple call to nf_log_register.
> 
> No, I think we only fix the comment (state PF_BRIDGE in the comment) but
> leave it like it is.

OK, but please fix the typo then. Shouldn't a similar comment be in
ebt_ulog?

cheers,
Bart




-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
