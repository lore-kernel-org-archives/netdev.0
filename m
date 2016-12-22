From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v3 2/4] ifstat: Add extended statistics to
 ifstat
Date: Thu, 22 Dec 2016 10:59:19 -0800
Message-ID: <20161222105919.08b8738b@xeon-e3>
References: <1482423795-6531-1-git-send-email-nogahf@mellanox.com>
        <1482423795-6531-3-git-send-email-nogahf@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        roszenrami@gmail.com, ogerlitz@mellanox.com, jiri@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, idosch@mellanox.com
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36521 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933582AbcLVS71 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 13:59:27 -0500
Received: by mail-pg0-f50.google.com with SMTP id f188so100548127pgc.3
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2016 10:59:27 -0800 (PST)
In-Reply-To: <1482423795-6531-3-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Dec 2016 18:23:13 +0200
Nogah Frankel <nogahf@mellanox.com> wrote:
On Thu, 22 Dec 2016 18:23:13 +0200
Nogah Frankel <nogahf@mellanox.com> wrote:

>  }
> @@ -691,18 +804,22 @@ static const struct option longopts[] = {
>  	{ "interval", 1, 0, 't' },
>  	{ "version", 0, 0, 'V' },
>  	{ "zeros", 0, 0, 'z' },
> +	{ "extended", 1, 0, 'x'},
>  	{ 0 }
>  };
>  
> +
>  int main(int argc, char *argv[])

You let extra whitespace changes creep in.


> +		case 'x':
> +			is_extended = true;
> +			memset(stats_type, 0, 64);
> +			strncpy(stats_type, optarg, 63);
> +			break;

This seems like doing this either the paranoid or hard way.
Why not:
	const char *stats_type = NULL;
...

	case 'x':
		stats_type = optarg;
		break;
...
		if (stats_type)
			snprintf(hist_name, sizeof(hist_name),
				 "%s/.%s_ifstat.u%d", P_tmpdir, stats_type,
				 getuid());
		else
			snprintf(hist_name, sizeof(hist_name),
				 "%s/.ifstat.u%d", P_tmpdir, getuid());


Since:
	1) optarg points to area in argv that is persistent (avoid copy)
	2) don't need is_extended flag value then

Please cleanup and resubmit.
