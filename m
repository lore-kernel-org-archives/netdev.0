From: anand@eis.iisc.ernet.in (SVR Anand)
Subject: tcp flows hash function
Date: Wed, 4 Dec 2002 13:08:31 +0530 (GMT+05:30)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200212040738.NAA02825@eis.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I am writing a program that requires maintanence of per-connection statistics
of many tcp connections based on multi-field classification. The problem is
that of fast search and update when there are 1000s of connections. Couple of
questions.

1. In many places of network code, I am seeing hashing being used. Can I also
use the same ? 

>From the recently published literature on packet classification, people are 
talking about some sort of trie variants. I would like to know if someone has 
done performance comparison of the algorithm used in Linux against other
schemes.
   

2. While going through tcp_ipv4.c, I happened to see tcp_hashfn. What is the
algorithm behind this ?

static __inline__ int tcp_hashfn(__u32 laddr, __u16 lport,
                                 __u32 faddr, __u16 fport)
{
        int h = ((laddr ^ lport) ^ (faddr ^ fport));
        h ^= h>>16;
        h ^= h>>8;
        return h & (tcp_ehash_size - 1);
}


Any inputs from you will help me proceed further.

Anand
