From: Zilvinas Valinskas <zilvinas@gemtek.lt>
Subject: Re: Crypto tests via tcrypt.o modules failes
Date: Fri, 17 Sep 2004 10:56:33 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095407793.4174.10.camel@swoop.gemtek.lt>
References: <Xine.LNX.4.44.0409161528250.4676-100000@thoron.boston.redhat.com>
Reply-To: zilvinas@gemtek.lt
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0409161528250.4676-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

strings like "dst_output: 0" in tcrypto-tests is due to this patch :

--- include/net/dst.h   (revision 1173)
+++ include/net/dst.h   (working copy)
@@ -217,6 +217,7 @@
 
        for (;;) {
                err = skb->dst->output(skb);
+               printk("dst_output: %d\n", err);
 
                if (likely(err == 0))
                        return err;
@@ -232,6 +233,7 @@
 
        for (;;) {
                err = skb->dst->input(skb);
+               printk("dst_input: %d\n", err);
 
                if (likely(err == 0))
                        return err;


On Thu, 2004-09-16 at 22:29, James Morris wrote:
> On Thu, 16 Sep 2004, Zilvinas Valinskas wrote:
> 
> > I would say Xscale IXP425 has a rather interesting 32, 16 bits
> > read/write results if address is not aligned properly.
> 
> Odd, no other algorithms seem to be having any problems.  Can you post 
> your .config?
> 
> 
> - James
