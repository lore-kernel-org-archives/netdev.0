From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 02 Jan 2011 22:33:13 +0100
Message-ID: <1294003993.5675.3.camel@wall-e>
References: <1293982286-15389-1-git-send-email-stefani@seibold.net>
	 <AANLkTi=7M=gSgBjcrCVEj+GKZ5cf5t4MPqm6r9NGr=MZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=7M=gSgBjcrCVEj+GKZ5cf5t4MPqm6r9NGr=MZ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, den 02.01.2011, 21:48 +0200 schrieb Daniel Baluta:
> Hello,
> 
> I have some style comments, please read below.
> 
> > +struct udpcp_statistics {
> > +       unsigned int txMsgs;            /* Num of transmitted messages */
> > +       unsigned int rxMsgs;            /* Num of received messages */
> > +       unsigned int txNodes;           /* Num of receiver nodes */
> > +       unsigned int rxNodes;           /* Num of transmitter nodes */
> > +       unsigned int txTimeout;         /* Num of unsuccessful transmissions */
> > +       unsigned int rxTimeout;         /* Num of partial message receptions */
> > +       unsigned int txRetries;         /* Num of resends */
> > +       unsigned int rxDiscardedFrags;  /* Num of discarded fragments */
> > +       unsigned int crcErrors;         /* Num of crc errors detected */
> 
> Is there any strong reason to have this camel case naming?
> I would prefer tx_msgs, rx_msgs etc..
> 

This cannot be fixed for compatiblity reasons.

> > +struct udpcp_dest {
> > +       struct list_head list;
> > +       struct sk_buff_head xmit;
> > +       unsigned long tx_time;
> > +       unsigned long rx_time;
> > +       u32 txTimeout;
> > +       u32 rxTimeout;
> 
> Here you have mixed naming conventions. I guess
> tx_timeout will fit in better than txTimeout.
> 
> > +       u32 txRetries;
> > +       u32 rxDiscardedFrags;
> > +       struct sk_buff *xmit_wait;
> > +       struct sk_buff *xmit_last;
> > +       struct sk_buff *recv_msg;
> > +       struct sk_buff *recv_last;
> > +       struct udpcphdr lastmsg;
> > +       struct ipcm_cookie ipc;
> > +       struct flowi fl;
> > +       struct rtable *rt;
> > +       __be32 addr;
> > +       __be16 port;
> > +       u16 msgid;
> > +       u8 use_flag;
> > +       u8 insync;
> > +       u8 ackmode;
> > +       u8 chkmode;
> > +       u8 try;
> > +       u8 acks;
> > +       struct udp_sock udpsock;
> > +       struct sk_buff_head assembly;
> > +       u32 assembly_len;
> > +       struct udpcp_dest *assembly_dest;
> > +       wait_queue_head_t wq;
> > +       struct list_head destlist;
> > +       struct list_head udpcplist;
> > +       struct timer_list timer;
> > +       struct udpcp_statistics stat;
> > +       u32 pending;
> > +       unsigned long tx_timeout;
> > +       unsigned long rx_timeout;
> > +       void (*udp_data_ready) (struct sock *sk, int bytes);
> > +       u8 ackmode;
> > +       u8 chkmode;
> > +       u8 maxtry;
> > +       u8 acks;
> > +       u8 timeout;
> > +/* overall UDPCP statistics */
> > +static atomic_t udpcp_txMsgs;
> > +static atomic_t udpcp_rxMsgs;
> > +static atomic_t udpcp_txNodes;
> > +static atomic_t udpcp_rxNodes;
> > +static atomic_t udpcp_txTimeout;
> > +static atomic_t udpcp_rxTimeout;
> > +static atomic_t udpcp_txRetries;
> > +static atomic_t udpcp_rxDiscardedFrags;
> > +static atomic_t udpcp_crcErrors;
> 
> same here.
> 

I think there is no nameing convention in linux, as i know it is a
developer decision.
