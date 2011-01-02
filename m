From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 2 Jan 2011 21:48:15 +0200
Message-ID: <AANLkTi=7M=gSgBjcrCVEj+GKZ5cf5t4MPqm6r9NGr=MZ@mail.gmail.com>
References: <1293982286-15389-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293982286-15389-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have some style comments, please read below.

> +struct udpcp_statistics {
> + =A0 =A0 =A0 unsigned int txMsgs; =A0 =A0 =A0 =A0 =A0 =A0/* Num of t=
ransmitted messages */
> + =A0 =A0 =A0 unsigned int rxMsgs; =A0 =A0 =A0 =A0 =A0 =A0/* Num of r=
eceived messages */
> + =A0 =A0 =A0 unsigned int txNodes; =A0 =A0 =A0 =A0 =A0 /* Num of rec=
eiver nodes */
> + =A0 =A0 =A0 unsigned int rxNodes; =A0 =A0 =A0 =A0 =A0 /* Num of tra=
nsmitter nodes */
> + =A0 =A0 =A0 unsigned int txTimeout; =A0 =A0 =A0 =A0 /* Num of unsuc=
cessful transmissions */
> + =A0 =A0 =A0 unsigned int rxTimeout; =A0 =A0 =A0 =A0 /* Num of parti=
al message receptions */
> + =A0 =A0 =A0 unsigned int txRetries; =A0 =A0 =A0 =A0 /* Num of resen=
ds */
> + =A0 =A0 =A0 unsigned int rxDiscardedFrags; =A0/* Num of discarded f=
ragments */
> + =A0 =A0 =A0 unsigned int crcErrors; =A0 =A0 =A0 =A0 /* Num of crc e=
rrors detected */

Is there any strong reason to have this camel case naming?
I would prefer tx_msgs, rx_msgs etc..

> +struct udpcp_dest {
> + =A0 =A0 =A0 struct list_head list;
> + =A0 =A0 =A0 struct sk_buff_head xmit;
> + =A0 =A0 =A0 unsigned long tx_time;
> + =A0 =A0 =A0 unsigned long rx_time;
> + =A0 =A0 =A0 u32 txTimeout;
> + =A0 =A0 =A0 u32 rxTimeout;

Here you have mixed naming conventions. I guess
tx_timeout will fit in better than txTimeout.

> + =A0 =A0 =A0 u32 txRetries;
> + =A0 =A0 =A0 u32 rxDiscardedFrags;
> + =A0 =A0 =A0 struct sk_buff *xmit_wait;
> + =A0 =A0 =A0 struct sk_buff *xmit_last;
> + =A0 =A0 =A0 struct sk_buff *recv_msg;
> + =A0 =A0 =A0 struct sk_buff *recv_last;
> + =A0 =A0 =A0 struct udpcphdr lastmsg;
> + =A0 =A0 =A0 struct ipcm_cookie ipc;
> + =A0 =A0 =A0 struct flowi fl;
> + =A0 =A0 =A0 struct rtable *rt;
> + =A0 =A0 =A0 __be32 addr;
> + =A0 =A0 =A0 __be16 port;
> + =A0 =A0 =A0 u16 msgid;
> + =A0 =A0 =A0 u8 use_flag;
> + =A0 =A0 =A0 u8 insync;
> + =A0 =A0 =A0 u8 ackmode;
> + =A0 =A0 =A0 u8 chkmode;
> + =A0 =A0 =A0 u8 try;
> + =A0 =A0 =A0 u8 acks;
> + =A0 =A0 =A0 struct udp_sock udpsock;
> + =A0 =A0 =A0 struct sk_buff_head assembly;
> + =A0 =A0 =A0 u32 assembly_len;
> + =A0 =A0 =A0 struct udpcp_dest *assembly_dest;
> + =A0 =A0 =A0 wait_queue_head_t wq;
> + =A0 =A0 =A0 struct list_head destlist;
> + =A0 =A0 =A0 struct list_head udpcplist;
> + =A0 =A0 =A0 struct timer_list timer;
> + =A0 =A0 =A0 struct udpcp_statistics stat;
> + =A0 =A0 =A0 u32 pending;
> + =A0 =A0 =A0 unsigned long tx_timeout;
> + =A0 =A0 =A0 unsigned long rx_timeout;
> + =A0 =A0 =A0 void (*udp_data_ready) (struct sock *sk, int bytes);
> + =A0 =A0 =A0 u8 ackmode;
> + =A0 =A0 =A0 u8 chkmode;
> + =A0 =A0 =A0 u8 maxtry;
> + =A0 =A0 =A0 u8 acks;
> + =A0 =A0 =A0 u8 timeout;
> +/* overall UDPCP statistics */
> +static atomic_t udpcp_txMsgs;
> +static atomic_t udpcp_rxMsgs;
> +static atomic_t udpcp_txNodes;
> +static atomic_t udpcp_rxNodes;
> +static atomic_t udpcp_txTimeout;
> +static atomic_t udpcp_rxTimeout;
> +static atomic_t udpcp_txRetries;
> +static atomic_t udpcp_rxDiscardedFrags;
> +static atomic_t udpcp_crcErrors;

same here.

> +
> +module_param(debug, int, 0);
> +MODULE_PARM_DESC(debug, "Debug enabled or not");
> +

thanks,
Daniel.
