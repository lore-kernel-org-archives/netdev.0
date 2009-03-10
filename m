From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match (iptables)
Date: Tue, 10 Mar 2009 17:12:09 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0903101708150.19523@fbirervta.pbzchgretzou.qr>
References: <20090310151357.GA10658@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090310151357.GA10658@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>static void osf_init(struct xt_entry_match *m)
>{
>}
>
You can remove this function, as it does no initialization.
Implicit NULL in struct xtables_match is handled.

>		case '2': /* --ttl */
>			if (*flags & IPT_OSF_TTL)
>				exit_error(PARAMETER_PROBLEM, "Can't specify multiple ttl parameter");
>			*flags |= IPT_OSF_TTL;
>			info->flags |= IPT_OSF_TTL;
>			info->ttl = atoi(argv[optind-1]);

This would allow specifying --ttl 12345.

Use of xtables_strtoui (v1.4.3-rc1+git) for bounds checking,
and use of optarg seem beneficial:

	unsigned int num;

	if (!xtables_strtoui(optarg, NULL, &num, 0, UINT8_MAX))
		exit_error(PARAMETER_PROBLEM, "*shrug*");
	info->ttl = num;

>		case '3': /* --log */
>			if (*flags & IPT_OSF_LOG)
>				exit_error(PARAMETER_PROBLEM, "Can't specify multiple log parameter");
>			*flags |= IPT_OSF_LOG;
>			info->loglevel = atoi(argv[optind-1]);

similarly.

>			info->flags |= IPT_OSF_LOG;
>			break;
>[...]
>	return 1;
>}
>
>static void osf_final_check(unsigned int flags)
>{
>	if (!flags)
>		exit_error(PARAMETER_PROBLEM, "OS fingerprint match: You must specify `--genre'");
>}
>
>static struct xtables_match osf_match = {
>	.name		= "osf",
>	.version	= XTABLES_VERSION,
>	.size		= XT_ALIGN(sizeof(struct ipt_osf_info)),
>	.userspacesize	= XT_ALIGN(sizeof(struct ipt_osf_info)),
>	.help		= osf_help,
>	.init		= osf_init,
>	.parse		= osf_parse,
>	.print		= osf_print,
>	.final_check	= osf_final_check,
>	.save		= osf_save,
>	.extra_opts	= osf_opts
>};

Needs .family = NFPROTO_IPV4.
