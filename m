From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH 1/5] TCP infrastructure split out
Date: Sat, 19 Mar 2005 02:16:40 +0000
Message-ID: <423B8B88.70504@ev-en.org>
References: <20050318162221.501ff05a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@digeo.com>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com, Injong Rhee <rhee@eos.ncsu.edu>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050318162221.501ff05a@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

 > @@ -1356,7 +1301,7 @@
 >  static inline void __tcp_enter_cwr(struct tcp_sock *tp)
 >  {
 >  	tp->undo_marker = 0;
 > -	tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
 > +	tp->snd_ssthresh = tp->ca_proto->ssthresh(tp);

 > +void tcp_ca_register(struct tcp_ca_type *ca)
 > +{
 > +	BUG_ON(tcp_ca_find(ca->name));
 > +
 > +	spin_lock_irq(&tcp_ca_list_lock);
 > +	list_add_tail_rcu(&ca->list, &tcp_ca_list);
 > +	spin_unlock_irq(&tcp_ca_list_lock);
 > +
 > +	printk(KERN_INFO "TCP %s registered\n", ca->name);
 > +}

Since we have some calls to callbacks unprotected, shouldn't we check 
them on tcp_ca_register to make sure they are in fact available so that 
we don't needlessly crash?

Baruch
