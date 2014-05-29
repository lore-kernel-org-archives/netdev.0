From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net] team: fix mtu setting
Date: Thu, 29 May 2014 16:33:19 -0300
Message-ID: <20140529193319.GB13007@t520.home>
References: <1401389177-10463-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64185 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754003AbaE2TdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 15:33:25 -0400
Content-Disposition: inline
In-Reply-To: <1401389177-10463-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 08:46:17PM +0200, Jiri Pirko wrote:
> Now it is not possible to set mtu to team device which has a port
> enslaved to it. The reason is that when team_change_mtu() calls
> dev_set_mtu() for port device, notificator for NETDEV_PRECHANGEMTU
> event is called and team_device_event() returns NOTIFY_BAD forbidding
> the change. So fix this by returning NOTIFY_DONE here in case team is
> changing mtu in team_change_mtu().
> 
> Introduced-by: 3d249d4c "net: introduce ethernet teaming device"
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

Alright, so changing the team's mtu is now allowed but changing
port's mtu isn't allowed.
LGTM.

Since there are some common code between the unwide and the
successful code paths, I'd suggest to simply use:
...
	list_for_each_entry() {
		err = 
		if (err)
			break
	}

	if (err) {
		unwind
	}
	else
		dev->mtu = new_mtu;

	<common code>

But I suspect that due to the long function name, any
additional indentation there will cause the code to look
less readable.

Acked-by: Flavio Leitner <fbl@redhat.com>
