From: Zhikui Chen <zhikui.chen@rus.uni-stuttgart.de>
Subject: An issue on one network development.
Date: Fri, 20 Aug 2004 19:17:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41263245.8050305@rus.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, majordomo@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dear all,

HELP!

I am writing a DCCP code in Linux kernel 2.6.6,  I met a problem, which 
bored me about two weeks. Hope you to give me some hints, thanks in 
advance. The problem is on structure sock in dccp_lookup_listen of 
dccp_lookup.

When dccp_rcv (similar to udp_rcv and TCP_*_rcv) called dccp_v4_lookup( 
similar to TCP_v4_lookup),  the dccp_v4_lookup will call 
dccp_v4_lookup_listen. Running is dead when the 7th line is implemented, 
I checked, problem is from sk=__sk_head(head).  And I also checked the 
printed value of __sk_head(head) is correct.
The other way, I changed the first line as struct sock *sk; (remove 
"=NULL"), running is dead here. I doubt the problem belongs to memory.

My dccp_v4_lookup is so that:
static inline struct sock *dccp_v4_lookup_listen(u32 daddr, u16 
dport,int dif)
{
   struct sock *sk = NULL;
   struct hlist_head *head;

  read_lock(&dccp_lhash_lock);
 head = &dccp_hash[ntohs(dport) & (DCCP_HTABLE_SIZE - 1)];
   if (!hlist_empty(head)) {
       struct inet_opt *inet = inet_sk(sk  = __sk_head(head));

       if (inet->num == ntohs(dport) && !(sk->sk_node.next &&
           (!inet->rcv_saddr || inet->rcv_saddr == daddr) &&
           (sk->sk_family == PF_INET || !ipv6_only_sock(sk)) &&
           !sk->sk_bound_dev_if)
           goto sherry_cache;
   printk("dccp_v4_lookup_listen: sk:%x\n",(__sk_head(head)));
       //sk = __dccp_v4_lookup_listen(head, daddr, ntohs(dport), dif);
   }
   if (sk) {
sherry_cache:
       sock_hold(sk);
   }
   read_unlock(&dccp_lhash_lock);
   return (sk);

}

Best regards,

Zhikui Chen
In stuttgart university.
