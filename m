From: Janice M Girouard <janiceg@us.ibm.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 15:59:11 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEE2F9F.60706@us.ibm.com>
References: <3EEE28DE.6040808@us.ibm.com> <20030616.133841.35533284.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   Daniel Stekloff
 <stekloff@us.ibm.com>,
   Janice Girouard <girouard@us.ibm.com>, Larry Kessler
 <lkessler@us.ibm.com>,
   kenistonj@us.ibm.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I agree that it's not desirable to introduce a bunch of messages that we 
aren't already logging.  I didn't show the netif_msg prefix because I 
was trying to focus the patch on the common messages, but you would 
normally proceed a message with:

if netif_msg_link()
   printk("some text to indicate the link is up/down")

The netif_msg_link test would normally filter out what messages should 
be logged.

Or, just leave out the message call.  I added one or two messages to the 
tg3 and e1000 drivers  to demonstrate where you might use these common 
messages... just to show that various drivers could use the text. 
 Actually using the specific message would be completely up to the 
developer.

Jaince



David S. Miller wrote:

>   From: Janice M Girouard <janiceg@us.ibm.com>
>   Date: Mon, 16 Jun 2003 15:30:22 -0500
>
>   EMSG_NET_LINK_UP     "%s: state change: link up, %d Mbps, %s-duplex\n"
>
>Should indicate flow control state too.
>
>   EMSG_NET_START_QUEUE "%s: performance event: (re)starting netdev queue\n"
>   EMSG_NET_STOP_QUEUE  "%s: performance event: stopping netdev queue\n"
>
>Oh _ABSOLUTELY NOT_, you're not printing a message
>for normal events like this.  Especially those that are
>going to occur on highly loaded systems.
>
>  
>
