From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.5.70] acenic -- update to use alloc_etherdev
Date: Wed, 11 Jun 2003 22:44:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE81345.6080009@osdl.org>
References: <20030611144249.7cd63c1c.shemminger@osdl.org>	<m3y90845nu.fsf@trained-monkey.org> <20030611.210445.21901735.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jes@wildopensource.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030611.210445.21901735.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>   From: Jes Sorensen <jes@wildopensource.com>
>   Date: 11 Jun 2003 18:21:09 -0400
>
>   >>>>> "Stephen" == Stephen Hemminger <shemminger@osdl.org> writes:
>   
>   Stephen> Updated acenic driver to use alloc_etherdev to hold private
>   Stephen> data structure.  Uses register_netdev() to get the name right
>   Stephen> this time ;-)
>   
>   Please provide a compat macro for 2.4.18 and younger as well.
>
>How actively are you maintaining acenic. Jes?  :-)  This is
>a very serious question, I haven't seen a 2.5.x change go back
>to 2.4.x since it's inception.
>
>All this compat nonsense is becoming useless.  Other drivers
>fair just fine 2.4.x/2.5.x without all this ifdef mumbo-jumbo
>that litters acenic.c and makes it nearly impossible to read.
>
>In fact all these localized compat macros make acenic.c HARDER
>to maintain.
>  
>
The funny thing is this alloc_etherdev patch did not change the 
compatiablity one bit.
Just for grins, took the 2.5 driver back into the 2.4.18 and it doesn't 
build.
The problem is it doesn't know what irqreturn_t is.  The enclosed
cribbed from atm/he.c fixes that, but it still redefines local_irq_save etc.

Maybe it is time to stop the insanity.

diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c    Wed Jun 11 22:36:43 2003
+++ b/drivers/net/acenic.c    Wed Jun 11 22:36:43 2003
@@ -188,6 +188,13 @@
 #define ACE_MOD_DEC_USE_COUNT        do{} while(0)
 #endif
 
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,69)
+typedef void irqreturn_t;
+#define IRQ_NONE
+#define IRQ_HANDLED
+#define IRQ_RETVAL(x)
+#endif
+
 #ifndef SET_NETDEV_DEV
 #define SET_NETDEV_DEV(net, pdev)    do{} while(0)
 #endif
