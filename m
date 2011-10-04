From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 3/3] ethtool: add ETHTOOL_{G,S}CHANNEL support.
Date: Tue, 04 Oct 2011 23:21:42 +0100
Message-ID: <1317766902.2751.25.camel@bwh-desktop>
References: <1316514695-17157-1-git-send-email-sucheta.chakraborty@qlogic.com>
	 <1316514695-17157-4-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5854 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933180Ab1JDWVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 18:21:47 -0400
In-Reply-To: <1316514695-17157-4-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-20 at 03:31 -0700, Sucheta Chakraborty wrote:
> Used to configure number of rx and tx rings.
> Reqd. man page changes are included.
[...]
> @@ -754,6 +764,24 @@ lB	l.
>  Specify the location/ID to insert the rule. This will overwrite
>  any rule present in that location and will not go through any
>  of the rule ordering process.
> +.TP
> +.B \-l \-\-show\-channels
> +Queries the specified network device for channel parameter information.
> +.TP
> +.B \-L \-\-set\-channels
> +Changes the channel parameters of the specified network device.

I think the manual page needs to explain briefly what is meant by a
channel.  (So should ethtool.h, really!)

[...]
> @@ -495,6 +512,13 @@ static struct cmdline_info cmdline_ring[] = {
>  	{ "tx", CMDL_S32, &ring_tx_wanted, &ering.tx_pending },
>  };
>  
> +static struct cmdline_info cmdline_channels[] = {
> +	{ "rx_count", CMDL_S32, &channels_rx_wanted, &echannels.rx_count },
> +	{ "tx_count", CMDL_S32, &channels_tx_wanted, &echannels.tx_count },
> +	{ "other_count", CMDL_S32, &channels_other_wanted, &echannels.other_count },
> +	{ "combined_count", CMDL_S32, &channels_combined_wanted, &echannels.combined_count },
> +};

I don't think it's necessary to include '_count' in these keywords.

[...]
> @@ -1751,6 +1785,32 @@ static int dump_ring(void)
>  	return 0;
>  }
>  
> +static int dump_channels(void)
> +{
> +	fprintf(stdout,
> +		"Re-set maximums:\n"

Should 'Re-set' be 'Pre-set'?

> +		"Max RX:		%u\n"
> +		"Max TX:		%u\n"
> +		"Max Other:	%u\n"
> +		"Max Combined:	%u\n",
> +		echannels.max_rx, echannels.max_tx,
> +		echannels.max_other,
> +		echannels.max_combined);

The heading says they are maximums, so I don't think it's necessary to
include 'Max' on each line.

> +	fprintf(stdout,
> +		"Current hardware settings:\n"
> +		"RX Count:	%u\n"
> +		"TX Count:	%u\n"
> +		"Other Count:	%u\n"
> +		"Combined Count:	%u\n",

I don't think it's necessary to include 'Count' on each line here,
either.

[...]
> @@ -2114,6 +2178,58 @@ static int do_gring(int fd, struct ifreq *ifr)
>  	return 0;
>  }
>  
> +static int do_schannels(int fd, struct ifreq *ifr)
> +{
> +	int err, changed = 0;
> +
> +	echannels.cmd = ETHTOOL_GCHANNELS;
> +	ifr->ifr_data = (caddr_t)&echannels;
> +	err = send_ioctl(fd, ifr);
> +	if (err) {
> +		perror("Cannot get device channels settings");
> +		return 1;
> +	}
> +
> +	do_generic_set(cmdline_channels, ARRAY_SIZE(cmdline_channels),
> +			&changed);
> +
> +	if (!changed) {
> +		fprintf(stderr, "no channels parameters changed, aborting\n");
> +		return 1;
> +	}
[...]

These messages (and others below) are not grammatical.  They should say
'channel settings' or 'channel parameters'.

Actually, you could be more specific about what the parameters are, and
just write 'numbers of channels'.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
