From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [PATCH RFC 10/10] dpaa_eth: add trace points
Date: Fri, 3 Apr 2015 17:29:49 +0000
Message-ID: <BL2PR03MB545935082A02251893B5070E6F10@BL2PR03MB545.namprd03.prod.outlook.com>
References: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-2-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-3-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-4-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-5-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-6-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-7-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-8-git-send-email-madalin.bucur@freescale.com>
	 <1427905196-27778-9-git-send-email-madalin.bucur@freescale.com>
 <1428079621.13180.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ruxandra.radulescu@freescale.com" <ruxandra.radulescu@freescale.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428079621.13180.10.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
>
> On Wed, 2015-04-01 at 19:19 +0300, Madalin Bucur wrote:
> > Add trace points on the hot processing path.
> 
> more trivia:
> 
> > diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_trace.h
> b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_trace.h
> []
> > +#define fd_format_name(format)	{ qm_fd_##format, #format }
> > +#define fd_format_list	\
> > +	fd_format_name(contig),	\
> > +	fd_format_name(sg)
> 
> Are these used anywhere?

Yes, by the Frame Descriptor print:

        /* This is what gets printed when the trace event is triggered */
        TP_printk(TR_FMT,
                  __get_str(name), __entry->fqid, __entry->fd_addr,
                  __print_symbolic(__entry->fd_format, fd_format_list), 		// <-- here
                  __entry->fd_offset, __entry->fd_length, __entry->fd_status)


> > +#define TR_FMT "[%s] fqid=%d, fd: addr=0x%llx, format=%s, off=%u,
> len=%u," \
> > +	" status=0x%08x"
> 
> It's nicer to coalesce string fragments.
> 
> Unless this is intended to be used more than once,
> perhaps it's better to remove it and use the string
> directly instead.
> 
> > +	/* This is what gets printed when the trace event is triggered */
> > +	TP_printk(TR_FMT,
> > +		  __get_str(name), __entry->fqid, __entry->fd_addr,
> > +		  __print_symbolic(__entry->fd_format, fd_format_list),
> > +		  __entry->fd_offset, __entry->fd_length, __entry-
> >fd_status)
> 

Checkpatch seems to be less forgiving if the long string is not in a printk:

WARNING: line over 80 characters
#22: FILE: drivers/net/ethernet/freescale/dpaa/dpaa_eth_trace.h:47:
+#define TR_FMT "[%s] fqid=%d, fd: addr=0x%llx, format=%s, off=%u, len=%u, status=0x%08x"

Madalin
