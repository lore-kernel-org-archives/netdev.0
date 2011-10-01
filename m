From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [RFC patch net-next-2.6] net: introduce ethernet teaming device
Date: Sat, 1 Oct 2011 10:15:35 +0200
Message-ID: <20111001081534.GB1982@minipsycho.orion>
References: <1317386643-3041-1-git-send-email-jpirko@redhat.com>
 <20110930092619.6b45087d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	fubar@us.ibm.com, andy@greyhouse.net, tgraf@infradead.org,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50965 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342Ab1JAIPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Oct 2011 04:15:53 -0400
Content-Disposition: inline
In-Reply-To: <20110930092619.6b45087d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 30, 2011 at 06:26:19PM CEST, shemminger@vyatta.com wrote:
>On Fri, 30 Sep 2011 14:44:03 +0200
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> +static struct rtnl_link_stats64 *team_get_stats(struct net_device *dev,
>> +						struct rtnl_link_stats64 *stats)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct rtnl_link_stats64 temp;
>> +	struct team_port *port;
>> +
>> +	memset(stats, 0, sizeof(*stats));
>> +
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(port, &team->port_list, list) {
>> +		const struct rtnl_link_stats64 *pstats;
>
>You need to use u64_stats_sync macros to make this safe on 32 bit
>mode.

Well I'm doing this the same way it's done on several other place, as
for example bonding. 

>
>Also, I am not sure about the handling of speed and duplex.
>There are people who do active backup with links of different speeds.

Yes, team can handle multiple ifaces with different speeds and duplexes.
Why would you think it cannot?

>
>The team device doesn't seem to handle hardware offload features
>as completely as it should.  The TSO and transmit checksumming should
>be the union of the teamed ports.
>

Yeah, you are right here. I probably need something like
bond_compute_features() for team. Will add that.

Thank you Stephen.


Jirka
