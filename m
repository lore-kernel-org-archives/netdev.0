From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/8] net: dsa: directly fetch switch in lan9303_rcv
Date: Fri, 29 Sep 2017 15:04:56 -0400
Message-ID: <87lgkxl413.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com> <20170929183635.8122-3-vivien.didelot@savoirfairelinux.com> <e1fcff41-6ee7-e125-c7eb-98f6ba00a62d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e1fcff41-6ee7-e125-c7eb-98f6ba00a62d@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

>> @@ -72,11 +72,10 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
>>  {
>>  	u16 *lan9303_tag;
>>  	struct dsa_switch_tree *dst = dev->dsa_ptr;
>> -	struct dsa_switch *ds;
>> +	struct dsa_port *cpu_dp = dst->cpu_dp;
>> +	struct dsa_switch *ds = cpu_dp->ds;
>>  	unsigned int source_port;
>>  
>> -	ds = dst->ds[0];
>> -
>>  	if (unlikely(!ds)) {
>>  		dev_warn_ratelimited(&dev->dev, "Dropping packet, due to missing DSA switch device\n");
>>  		return NULL;
>
> Similarly to the patch before, you can probably drop this test, I don't
> actually see how we could trigger it.

Good catch, I'll respin after eventually more reviews.


Thanks,

        Vivien
