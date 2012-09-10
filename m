From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: (ipt_log_packet, sb_add) 3.6.0-rc2 kernel panic -
 not syncing; Fatal exception in interrupt
Date: Mon, 10 Sep 2012 08:00:05 +0200
Message-ID: <1347256805.1234.1087.camel@edumazet-glaptop>
References: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>
	<20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>
	<20120902132834.GB7456@breakpoint.cc>
	<1346626385.2563.44.camel@edumazet-glaptop>
	<alpine.LNX.2.01.1209100659220.22738@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sami Farin <hvtaifwkbgefbaei@gmail.com>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>, e1000-devel@lists.sourceforge.net
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LNX.2.01.1209100659220.22738@frira.zrqbmnf.qr>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2012-09-10 at 07:02 +0200, Jan Engelhardt wrote:
> On Monday 2012-09-03 00:53, Eric Dumazet wrote:
> >[PATCH] xt_LOG: take care of timewait sockets
> >
> >Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
> >full blown socket.
> >
> >But with TCP early demux, we can have skb->sk pointing to a timewait
> >socket.
> >
> >+static void dump_sk_uid_gid(struct sbuff *m, struct sock *sk)
> >+{
> >+	if (!sk || sk->sk_state == TCP_TIME_WAIT)
> >+		return;
> >+
> >+	read_lock_bh(&sk->sk_callback_lock);
> >+	if (sk->sk_socket && sk->sk_socket->file)
> >+		sb_add(m, "UID=%u GID=%u ",
> >+			sk->sk_socket->file->f_cred->fsuid,
> >+			sk->sk_socket->file->f_cred->fsgid);
> 
> xt_owner.c is also using f_cred, so it might need the same,
> does it not?

Right.

AFAIK, xt_owner would make little sense in input path, no ?

static struct xt_match owner_mt_reg __read_mostly = {
        .name       = "owner",
        .revision   = 1,
        .family     = NFPROTO_UNSPEC,
        .checkentry = owner_check,
        .match      = owner_mt,
        .matchsize  = sizeof(struct xt_owner_match_info),
        .hooks      = (1 << NF_INET_LOCAL_OUT) |
                      (1 << NF_INET_POST_ROUTING),
        .me         = THIS_MODULE,
};


So it seems we have nothing to do at this moment.





------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
