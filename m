From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next v2 3/9] ipv4: fib_rules: Dump FIB rules when
 registering FIB notifier
Date: Wed, 15 Mar 2017 17:36:18 +0200
Message-ID: <20170315153618.GB30399@splinter.mtl.com>
References: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
 <1489575912-6469-4-git-send-email-jiri@resnulli.us>
 <fc5a1b5e-e9e6-ad78-081d-d031ebed1a2c@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39189 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752871AbdCOPgV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 11:36:21 -0400
Content-Disposition: inline
In-Reply-To: <fc5a1b5e-e9e6-ad78-081d-d031ebed1a2c@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 09:22:10AM -0600, David Ahern wrote:
> On 3/15/17 5:05 AM, Jiri Pirko wrote:
> > @@ -2510,10 +2511,20 @@ static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
> >  		dev_warn(mlxsw_sp->bus_info->dev, "Failed to set abort trap.\n");
> >  }
> >  
> > +static bool mlxsw_sp_fib4_rule_default(const struct fib_rule *rule)
> > +{
> > +	if (!fib4_rule_matchall(rule) || rule->action != FR_ACT_TO_TBL ||
> > +	    (rule->table != RT_TABLE_LOCAL && rule->table != RT_TABLE_MAIN &&
> > +	     rule->table != RT_TABLE_DEFAULT))
> > +		return false;
> > +	return true;
> > +}
> > +
> 
> Since a default rule is defined by fib_default_rule_add(), and its
> callers, IPv4 and IPv6 should have the above as an exported helper.

OK. Will add this in IPv4 code. When we add support for IPv6 I'll do the
same there.

Thanks
