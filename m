From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6 3/5]: Use double-linked list for dev->qdisc_list
Date: Wed, 4 Aug 2004 09:43:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804094308.606f79bd.davem@redhat.com>
References: <410FAE42.2050909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <410FAE42.2050909@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 Aug 2004 17:24:50 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch changes dev->qdisc_list to a double-linked list. This solves
> the performance problems when destroying qdiscs with large number of inner
> qdiscs.

I don't see how this bit is correct:

@@ -831,7 +832,7 @@
 	read_unlock(&dev_base_lock);
 
 	cb->args[0] = idx;
-	cb->args[1] = q_idx;
+	cb->args[1] = q_idx - 1;
 
 	return skb->len;
 }

The changes to the qdisc_list traversal loop above this hunk does not
change what the final q_idx value is going to be.  The simplest
example is if the list is empty, for which q_idx will end up being
zero both before and after your changes.

Please enlighten me :)
