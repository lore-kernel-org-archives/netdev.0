From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC][PATCH 2/3] netlink check sender, audit
Date: Sat, 12 Feb 2005 17:48:11 +0100
Message-ID: <420E334B.8060805@eurodev.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <20050212010504.X24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net, jmorris@redhat.com,
        sds@epoch.ncsc.mil, serue@us.ibm.com
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050212010504.X24171@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Wright wrote:

>Add audit_check_sender() function for audit netlink messages.  This can also
>be used to set the loginuid, although I left that off for the moment.
>
>===== kernel/audit.c 1.9 vs edited =====
>--- 1.9/kernel/audit.c	2005-01-30 22:33:47 -08:00
>+++ edited/kernel/audit.c	2005-02-11 22:25:33 -08:00
>@@ -309,27 +309,36 @@ nlmsg_failure:			/* Used by NLMSG_PUT */
>  * Check for appropriate CAP_AUDIT_ capabilities on incoming audit
>  * control messages.
>  */
>-static int audit_netlink_ok(kernel_cap_t eff_cap, u16 msg_type)
>+static int audit_check_sender(struct sk_buff *skb)
> {
>-	int err = 0;
>+	struct nlmsghdr *nlh;
>+	u16 msg_type;
>+	int err = -EINVAL;
> 
>+	if (skb->len < NLMSG_LENGTH(0))
>+		goto out;
>+
>+	nlh = (struct nlmsghdr *)skb->data;
>+	msg_type = nlh->nlmsg_type;
>  
>

You're introducing some kind of check for malformed packets here as 
well, don't you think that such thing should be done by the receiver ?

I also see another option which is passing as parameter such function 
which check for capabilities/audit stuff to my netlink_process_skb 
function, calling it before process_msg. But in that case, the packet 
sent by a sender that doesn't has the right to was already enqueued. I 
understand that this is exactly what you are trying to avoid.

--
Pablo
