From: Stephen Smalley <sds@epoch.ncsc.mil>
Subject: Re: [RFC][PATCH 1/3] netlink check sender
Date: Mon, 14 Feb 2005 07:59:59 -0500
Message-ID: <1108385999.15437.18.camel@moss-spartans.epoch.ncsc.mil>
References: <20050212010109.V24171@build.pdx.osdl.net>
	 <20050212010243.W24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, James Morris <jmorris@redhat.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050212010243.W24171@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-02-12 at 04:02, Chris Wright wrote:
> ===== net/netlink/af_netlink.c 1.69 vs edited =====
> --- 1.69/net/netlink/af_netlink.c	2005-01-21 12:25:32 -08:00
> +++ edited/net/netlink/af_netlink.c	2005-02-11 18:05:59 -08:00
>  int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol)
>  {
>  	struct netlink_opt *nlk;
> -	int len = skb->len;
> -
> +	int err, len = skb->len;
> +	
>  	nlk = nlk_sk(sk);
> +
> +	printk("%s: %s(%d) send_check %p\n", __FUNCTION__, current->comm, current->pid, nlk->check_sender);
> +	if (nlk->check_sender)
> +		if ((err = nlk->check_sender(skb))) {
> +			netlink_detachskb(sk, skb);
> +			return err;
> +		}
> +

printk() is a leftover from debugging, I assume.  
Why place the check_sender() call here vs. just replacing the existing
security_netlink_send() call in netlink_sendmsg() with this new call?
 
-- 
Stephen Smalley <sds@epoch.ncsc.mil>
National Security Agency
