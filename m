From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 net-next] team: add ethtool support
Date: Mon, 31 Dec 2012 22:16:26 +0000
Message-ID: <1356992186.31299.1.camel@deadeye.wl.decadent.org.uk>
References: <1356835053-25602-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48989 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab2LaWQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 17:16:33 -0500
In-Reply-To: <1356835053-25602-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-12-30 at 00:37 -0200, Flavio Leitner wrote:
> This patch adds few ethtool operations to team driver.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
> v2 - removed generic statistics from ethtool
> 
>  drivers/net/team/team.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index ad86660..7665a088 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
[...]
> +static void team_ethtool_get_drvinfo(struct net_device *dev,
> +				     struct ethtool_drvinfo *drvinfo)
> +{
> +	strncpy(drvinfo->driver, DRV_NAME, 32);
> +	strncpy(drvinfo->version, UTS_RELEASE, 32);
> +}
[...]

These must be null-terminated, so use strlcpy() not strncpy().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
