From: Patrick McHardy <kaber@trash.net>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: Sun, 03 Apr 2005 17:47:51 +0200
Message-ID: <42501027.6010609@trash.net>
References: <1112319441.1089.83.camel@jzny.localdomain>	 <20050401042106.GA27762@gondor.apana.org.au>	 <1112353398.1096.116.camel@jzny.localdomain>	 <20050401114258.GA2932@gondor.apana.org.au>	 <1112358278.1096.160.camel@jzny.localdomain>	 <20050401123554.GA3468@gondor.apana.org.au>	 <1112403845.1088.14.camel@jzny.localdomain>	 <20050402012813.GA24575@gondor.apana.org.au>	 <1112406164.1088.54.camel@jzny.localdomain>	 <20050402014619.GB24861@gondor.apana.org.au>	 <1112469601.1088.173.camel@jzny.localdomain> <1112538718.1096.394.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112538718.1096.394.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
>>+void km_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
>> {
>>+	struct xfrm_mgr *km;
>>+
>>+	read_lock(&xfrm_km_lock);
>>+	list_for_each_entry(km, &xfrm_km_list, list)
>>+		if (km->notify_policy)
>>+			km->notify_policy(xp, dir, c);
>>+	read_unlock(&xfrm_km_lock);
>>+}
>>+
>>+void km_state_notify(struct xfrm_state *x, struct km_event *c)
>>+{
>>+	struct xfrm_mgr *km;
>>+	read_lock(&xfrm_km_lock);
>>+	list_for_each_entry(km, &xfrm_km_list, list)
>>+		km->notify(x, c);
>>+	read_unlock(&xfrm_km_lock);
>>+}

You call these functions from both softirq- and user-context, so you
need to protect against BHs.

Regards
Patrick
