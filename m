From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next] team: set IFF_TEAM_PORT priv_flag after
 rx_handler is registered
Date: Mon, 25 Aug 2014 14:11:15 -0700
Message-ID: <CAHA+R7NeOhhHu+RJ-zyOt_3PrY7qYk98r7gjH9Qz3Vf=Za_REA@mail.gmail.com>
References: <1408995507-10338-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, fbl@redhat.com,
	erik.hugne@ericsson.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:45290 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933436AbaHYVLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 17:11:16 -0400
Received: by mail-lb0-f179.google.com with SMTP id v6so320001lbi.10
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 14:11:15 -0700 (PDT)
In-Reply-To: <1408995507-10338-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2014 at 12:38 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> When one tries to add eth as a port into team and that eth is already in
> use by other rx_handler device (macvlan, bond, bridge, ...) a bug in
> team_port_add() causes that IFF_TEAM_PORT flag is set before rx_handler
> is registered. In between, netdev nofifier is called and
> team_device_event() sees IFF_TEAM_PORT and thinks that rx_handler_data
> pointer is set to team_port. But it isn't.
>
> Fix this by reordering rx_handler register and IFF_TEAM_PORT priv flag
> set so it is very similar to how bonding does this.
>
> Reported-by: Erik Hugne <erik.hugne@ericsson.com>
> Introduced-by: 3d249d4ca7 "net: introduce ethernet teaming device"
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

For consistence, we use "Fixes:" instead of "Introduced-by:".
Just fyi.
