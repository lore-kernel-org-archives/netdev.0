From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH 2/4] [NETLINK] introduce netlink_check_skb function
Date: Fri, 11 Feb 2005 22:31:40 +0100
Message-ID: <420D243C.4090507@eurodev.net>
References: <420BF8CB.6080005@eurodev.net> <20050211032448.GD31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050211032448.GD31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>>+/* 
>>+ * Process one packet of messages.
>>+ * Malformed skbs with wrong lengths of messages are discarded silently.
>>+ */
>>+int netlink_process_skb(struct sk_buff *skb, 
>>+			int (*process_msg)(struct sk_buff *skb,
>>+					   struct nlmsghdr *nlh,
>>+					   int *err))
>>+{
>>+	int err;
>>+	struct nlmsghdr * nlh;
>>+
>>+	while (skb->len >= NLMSG_SPACE(0)) {
>>    
>>
>
>While you're at it, change that to NLMSG_LENGTH(0) or even to
>NLMSG_ALIGN(sizeof(*nlh)) to make it more readable. NLMSG_SPACE()
>represents the total size of a netlink message in the byte stream
>including the padding to payload in order to enforce proper
>alignement for successive netlink message header.
>  
>

They are all the same thing. They all return 16 bytes which is the size 
of a netlink header. If you and someone else think that those are more 
readable, I'm ok with it, whatever. I just stole that piece of code as 
is from current checkings done in xfrm and rtnetlink.

--
Pablo
