From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH 5/6] 6lowpan: handle dev_queue_xmit
	error code properly
Date: Tue, 02 Apr 2013 15:30:24 -0400
Message-ID: <515B31D0.4050709@signal11.us>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
	<1364928481-1813-6-git-send-email-alan@signal11.us>
	<CAJmB2rB+9-gLV=SVvr4JUc2swjmTaWxD0gYM5VLw8PL1d455JA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2683892115291391733=="
Cc: "open list:NETWORKING \[GENERAL\]" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel <linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <CAJmB2rB+9-gLV=SVvr4JUc2swjmTaWxD0gYM5VLw8PL1d455JA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============2683892115291391733==
Content-Type: multipart/alternative;
	boundary="------------090100060109050406060200"

This is a multi-part message in MIME format.
--------------090100060109050406060200
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 04/02/2013 03:21 PM, Alexander Smirnov wrote:
>
>
>
> 2013/4/2 Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org <mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>>
>
>     dev_queue_xmit() can return positive error codes, so check for
>     nonzero.
>
>     Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org <mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>>
>     ---
>      net/ieee802154/6lowpan.c | 2 +-
>      1 file changed, 1 insertion(+), 1 deletion(-)
>
>     diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
>     index e1b4580..a68c792 100644
>     --- a/net/ieee802154/6lowpan.c
>     +++ b/net/ieee802154/6lowpan.c
>     @@ -1139,7 +1139,7 @@ static netdev_tx_t lowpan_xmit(struct
>     sk_buff *skb, struct net_device *dev)
>      error:
>             dev_kfree_skb(skb);
>      out:
>     -       if (err < 0)
>     +       if (err)
>
> lets say ok....
>
>                     pr_debug("ERROR: xmit failed\n");
>
>             return (err < 0 ? NETDEV_TX_BUSY : NETDEV_TX_OK);
>
> but here you still checks for negative error only, why?

That's fixed in the next patch (6/6). Maybe 5/6 and 6/6 should be
squashed? It's the same fundamental problem, but with different
implications (as described in the commit messages). 5/6 is about the
error (debug) message being not shown all the times it needs to be, and
6/6 is about returning the correct error code to the higher layer[1].

Alan.

[1] I'm never sure, given "make a patch do one thing only," where to
draw the line between having fewer patches which are larger, and having
more smaller patches which are easier to understand.


--------------090100060109050406060200
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 04/02/2013 03:21 PM, Alexander
      Smirnov wrote:<br>
    </div>
    <blockquote
cite="mid:CAJmB2rB+9-gLV=SVvr4JUc2swjmTaWxD0gYM5VLw8PL1d455JA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org"
      type="cite">
      <div dir="ltr"><br>
        <div class="gmail_extra"><br>
          <br>
          <div class="gmail_quote">2013/4/2 Alan Ott <span dir="ltr">&lt;<a
                moz-do-not-send="true" href="mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org"
                target="_blank">alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org</a>&gt;</span><br>
            <blockquote class="gmail_quote" style="margin:0 0 0
              .8ex;border-left:1px #ccc solid;padding-left:1ex">
              dev_queue_xmit() can return positive error codes, so check
              for nonzero.<br>
              <br>
              Signed-off-by: Alan Ott &lt;<a moz-do-not-send="true"
                href="mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org">alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org</a>&gt;<br>
              ---<br>
              &nbsp;net/ieee802154/6lowpan.c | 2 +-<br>
              &nbsp;1 file changed, 1 insertion(+), 1 deletion(-)<br>
              <br>
              diff --git a/net/ieee802154/6lowpan.c
              b/net/ieee802154/6lowpan.c<br>
              index e1b4580..a68c792 100644<br>
              --- a/net/ieee802154/6lowpan.c<br>
              +++ b/net/ieee802154/6lowpan.c<br>
              @@ -1139,7 +1139,7 @@ static netdev_tx_t
              lowpan_xmit(struct sk_buff *skb, struct net_device *dev)<br>
              &nbsp;error:<br>
              &nbsp; &nbsp; &nbsp; &nbsp; dev_kfree_skb(skb);<br>
              &nbsp;out:<br>
              - &nbsp; &nbsp; &nbsp; if (err &lt; 0)<br>
              + &nbsp; &nbsp; &nbsp; if (err)<br>
            </blockquote>
            <div>lets say ok.... <br>
            </div>
            <blockquote class="gmail_quote" style="margin:0 0 0
              .8ex;border-left:1px #ccc solid;padding-left:1ex">
              &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; pr_debug("ERROR: xmit failed\n");<br>
              <br>
              &nbsp; &nbsp; &nbsp; &nbsp; return (err &lt; 0 ? NETDEV_TX_BUSY :
              NETDEV_TX_OK);<br>
            </blockquote>
            <div>but here you still checks for negative error only, why?<br>
            </div>
          </div>
        </div>
      </div>
    </blockquote>
    <br>
    That's fixed in the next patch (6/6). Maybe 5/6 and 6/6 should be
    squashed? It's the same fundamental problem, but with different
    implications (as described in the commit messages). 5/6 is about the
    error (debug) message being not shown all the times it needs to be,
    and 6/6 is about returning the correct error code to the higher
    layer[1].<br>
    <br>
    Alan.<br>
    <br>
    [1] I'm never sure, given "make a patch do one thing only," where to
    draw the line between having fewer patches which are larger, and
    having more smaller patches which are easier to understand.<br>
    <br>
  </body>
</html>

--------------090100060109050406060200--


--===============2683892115291391733==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
--===============2683892115291391733==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-zigbee-devel mailing list
Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

--===============2683892115291391733==--
