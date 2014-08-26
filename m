From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] team: set IFF_TEAM_PORT priv_flag after
 rx_handler is registered
Date: Mon, 25 Aug 2014 17:36:11 -0700 (PDT)
Message-ID: <20140825.173611.1629035794825074435.davem@davemloft.net>
References: <1408995507-10338-1-git-send-email-jiri@resnulli.us>
	<CAHA+R7NeOhhHu+RJ-zyOt_3PrY7qYk98r7gjH9Qz3Vf=Za_REA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, fbl@redhat.com,
	erik.hugne@ericsson.com
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755155AbaHZAgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:36:12 -0400
In-Reply-To: <CAHA+R7NeOhhHu+RJ-zyOt_3PrY7qYk98r7gjH9Qz3Vf=Za_REA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Mon, 25 Aug 2014 14:11:15 -0700

> On Mon, Aug 25, 2014 at 12:38 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> When one tries to add eth as a port into team and that eth is already in
>> use by other rx_handler device (macvlan, bond, bridge, ...) a bug in
>> team_port_add() causes that IFF_TEAM_PORT flag is set before rx_handler
>> is registered. In between, netdev nofifier is called and
>> team_device_event() sees IFF_TEAM_PORT and thinks that rx_handler_data
>> pointer is set to team_port. But it isn't.
>>
>> Fix this by reordering rx_handler register and IFF_TEAM_PORT priv flag
>> set so it is very similar to how bonding does this.
>>
>> Reported-by: Erik Hugne <erik.hugne@ericsson.com>
>> Introduced-by: 3d249d4ca7 "net: introduce ethernet teaming device"
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> 
> For consistence, we use "Fixes:" instead of "Introduced-by:".
> Just fyi.

I fixed this up and applied the patch, thanks.
