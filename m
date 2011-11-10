From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V7] net: introduce ethernet teaming device
Date: Thu, 10 Nov 2011 17:59:45 +0100
Message-ID: <20111110165944.GA2078@minipsycho>
References: <1320939698-1062-1-git-send-email-jpirko@redhat.com>
 <1320940930.10042.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com, ivecera@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54283 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932832Ab1KJRAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 12:00:15 -0500
Content-Disposition: inline
In-Reply-To: <1320940930.10042.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 10, 2011 at 05:02:10PM CET, eric.dumazet@gmail.com wrote:
>Le jeudi 10 novembre 2011 =E0 16:41 +0100, Jiri Pirko a =E9crit :
>> This patch introduces new network device called team. It supposes to=
 be
>> very fast, simple, userspace-driven alternative to existing bonding
>> driver.
>>=20
>
>> +static bool team_dummy_transmit(struct team *team, struct sk_buff *=
skb)
>> +{
>> +	dev_kfree_skb(skb);
>> +	return false;
>> +}
>> +
>
>ndo_start_xmit() method can be called with IRQ disabled (netpoll ?), s=
o
>dev_kfree_skb_any() is better ?
>

=46or example bonding is using dev_kfree_skb in xmit as well.
I propose this to be eventually addressed in follow-up patch.


>
>
