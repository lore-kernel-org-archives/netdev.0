From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/4] net: dsa: assign a master to slave ports
Date: Sat, 2 Sep 2017 09:29:06 -0700
Message-ID: <153b5e2d-f904-3836-4eeb-0ef9698f7090@gmail.com>
References: <20170831183746.2109-1-vivien.didelot@savoirfairelinux.com>
 <20170831183746.2109-5-vivien.didelot@savoirfairelinux.com>
 <20170902153435.GB21003@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34940 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752697AbdIBQ3K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 12:29:10 -0400
In-Reply-To: <20170902153435.GB21003@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/02/2017 08:34 AM, Andrew Lunn wrote:
> On Thu, Aug 31, 2017 at 02:37:46PM -0400, Vivien Didelot wrote:
>> Because each DSA slave port may use a different DSA master port, add a
>> pointer to a master in the slave structure. This is a preparatory patch
>> for multiple CPU ports.
>>
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> ---
>>  net/dsa/dsa_priv.h |  7 ++-----
>>  net/dsa/slave.c    | 33 ++++++++++++++++++---------------
>>  2 files changed, 20 insertions(+), 20 deletions(-)
>>
>> diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
>> index 59f155cbbe87..a8cd6cbe4061 100644
>> --- a/net/dsa/dsa_priv.h
>> +++ b/net/dsa/dsa_priv.h
>> @@ -66,6 +66,8 @@ struct dsa_notifier_vlan_info {
>>  };
>>  
>>  struct dsa_slave_priv {
>> +	struct dsa_master *master;
>> +
>>  	/* Copy of the master xmit tagging op for faster access in hot path */
>>  	struct sk_buff *	(*xmit)(struct sk_buff *skb,
>>  					struct net_device *dev);
>> @@ -179,9 +181,4 @@ extern const struct dsa_device_ops qca_netdev_ops;
>>  /* tag_trailer.c */
>>  extern const struct dsa_device_ops trailer_netdev_ops;
>>  
>> -static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
>> -{
>> -	return p->dp->ds->dst->master->netdev;
>> -}
>> -
> 
> Hi Vivien
> 
> Why remove this helper, when it could become p->master->netdev ?

Agreed, I would keep the helper at this point to minimize the delta, it
should really identical in terms of code generated.
-- 
Florian
