From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match (iptables part)
Date: Thu, 12 Feb 2009 22:18:24 +0300
Message-ID: <20090212191824.GB17896@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121922280.20367@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0902121922280.20367@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 12, 2009 at 07:26:53PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
> >#include <xtables.h>
> >
> >typedef unsigned int __u32;
> >typedef unsigned short __u16;
> >typedef unsigned char __u8;
> 
> These should not done here.. it likely causes a "redefinition"
> warning or compile error of sorts. Include <linux/types.h> if
> in doubt.

It does not since linux/types.h header is not included, but better use
existing header of course.

> >static void osf_help(void)
> >{
> >	printf("OS fingerprint match options:\n"
> >		"--genre [!] string	Match a OS genre by passive fingerprinting.\n"
> 
> The syntax should be  [!] --genre string, that is what most
> others use. Then the check_inverse call also be removed.

ok.

> >static const struct option osf_opts[] = {
> >	{ .name = "genre",	.has_arg = 1, .flag = 0, .val = '1' },
> >	{ .name = "ttl",	.has_arg = 1, .flag = 0, .val = '2' },
> >	{ .name = "log",	.has_arg = 1, .flag = 0, .val = '3' },
> >	{ .name = "connector",	.has_arg = 0, .flag = 0, .val = '5' },
> >	{ .name = NULL }
> >};
> 
> .flag can be omitted; .has_arg=true
> 
> >			osf_parse_string(argv[optind-1], info);
> >			if (invert)
> >				info->flags |= IPT_OSF_INVERT;
> >			info->len=strlen((char *)info->genre);
> 
> This cast seems unnecessary.

Yup.

> >		case '2': /* --ttl */
> >			if (*flags & IPT_OSF_TTL)
> >				exit_error(PARAMETER_PROBLEM, "Can't specify multiple ttl parameter");
> >			*flags |= IPT_OSF_TTL;
> >			info->flags |= IPT_OSF_TTL;
> >			info->ttl = atoi(argv[optind-1]);
> 
> Make use of xtables_strtoui to do bounds checking on the TTL value.

Hmm...
$ grep xtables_strtoui -r /tmp/iptables-1.4.2
$

> >static void osf_save(const void *ip, const struct xt_entry_match *match)
> >{
> >	const struct ipt_osf_info *info = (const struct ipt_osf_info*) match->data;
> >
> >	printf("--genre %s%s ", (info->flags & IPT_OSF_INVERT) ? "! ": "", info->genre);
> >}
> 
> Similarly, put ! before.

ok.

> >static struct xtables_match osf_match = {
> >    .name		= "osf",
> >    .version		= XTABLES_VERSION,
> >    .size		= XT_ALIGN(sizeof(struct ipt_osf_info)),
> >    .userspacesize	= XT_ALIGN(sizeof(struct ipt_osf_info)),
> >    .help		= &osf_help,
> >    .init		= &osf_init,
> >    .parse		= &osf_parse,
> >    .print		= &osf_print,
> >    .final_check	= &osf_final_check,
> >    .save		= &osf_save,
> >    .extra_opts		= osf_opts
> 
> The & for function pointers is not needed (and actually makes
> macro substituion break in some cases, just in case I need
> an excuse)

Well, having & clearly shows it is a pointer and not a value, especially
when it is not clear from the name what it should be.

-- 
	Evgeniy Polyakov
