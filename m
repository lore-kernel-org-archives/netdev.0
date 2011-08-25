From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Scm: Remove unnecessary pid & credential references in
 Unix socket's send and receive path
Date: Wed, 24 Aug 2011 19:43:44 -0700 (PDT)
Message-ID: <20110824.194344.423083561694337662.davem@davemloft.net>
References: <1313772298.2576.2916.camel@schen9-DESK>
	<20110822.174013.353730308624819543.davem@davemloft.net>
	<1314061046.2576.2922.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, viro@zeniv.linux.org.uk,
	ebiederm@xmission.com, ak@linux.intel.com,
	matt.fleming@linux.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: tim.c.chen@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314061046.2576.2922.camel@schen9-DESK>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Mon, 22 Aug 2011 17:57:26 -0700

> On Mon, 2011-08-22 at 17:40 -0700, David Miller wrote:
>> From: Tim Chen <tim.c.chen@linux.intel.com>
>> Date: Fri, 19 Aug 2011 09:44:58 -0700
>> 
>> > -		/* Only send the fds in the first buffer */
>> > -		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent);
>> > +		/* Only send the fds and no ref to pid in the first buffer */
>> > +		if (fds_sent)
>> > +			err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, true);
>> > +		else
>> > +			err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, false);
>> 
>> Just set this final boolean the way the third argument is, there is no
>> reason to replicate the entire function call twice just to set the
>> final argument to what "fds_sent" evaluates to as a boolean.
>> 
>> 		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
>> 
>> ought to suffice.
> 
> Good point.  Patch updated as suggested.

Applied.
