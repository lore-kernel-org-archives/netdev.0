From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match (iptables part)
Date: Thu, 12 Feb 2009 21:19:18 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902122112280.670@fbirervta.pbzchgretzou.qr>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121922280.20367@fbirervta.pbzchgretzou.qr> <20090212191824.GB17896@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:35515 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbZBLUTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 15:19:19 -0500
In-Reply-To: <20090212191824.GB17896@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2009-02-12 20:18, Evgeniy Polyakov wrote:
>On Thu, Feb 12, 2009 at 07:26:53PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
>> >#include <xtables.h>
>> >
>> >typedef unsigned int __u32;
>> >typedef unsigned short __u16;
>> >typedef unsigned char __u8;
>> 
>> These should not done here.. it likely causes a "redefinition"
>> warning or compile error of sorts. Include <linux/types.h> if
>> in doubt.
>
>It does not since linux/types.h header is not included, but better use
>existing header of course.

Usually it happens to be slurped in via <xtables.h> or so;
since many xt_foobar.h files use __u32 too and we do not have
a problem with them, manually adding the typedefs seems redundant.

>> >		case '2': /* --ttl */
>> >			if (*flags & IPT_OSF_TTL)
>> >				exit_error(PARAMETER_PROBLEM, "Can't specify multiple ttl parameter");
>> >			*flags |= IPT_OSF_TTL;
>> >			info->flags |= IPT_OSF_TTL;
>> >			info->ttl = atoi(argv[optind-1]);
>> 
>> Make use of xtables_strtoui to do bounds checking on the TTL value.
>
>Hmm...
>$ grep xtables_strtoui -r /tmp/iptables-1.4.2
>$

It is going to be in 1.4.3, after whose release is the earliest point
ipt_osf (or xt_osf :) will probably find its way into the mainlines.
In 1.4.2, it is still called strtonum.

>> >    .save		= &osf_save,
>> >    .extra_opts		= osf_opts
>> 
>> The & for function pointers is not needed (and actually makes
>> macro substituion break in some cases, just in case I need
>> an excuse)
>
>Well, having & clearly shows it is a pointer and not a value, especially
>when it is not clear from the name what it should be.

I think we're good - there is no & in any other extension.
