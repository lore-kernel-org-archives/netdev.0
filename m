From: linux lover <linux_lover2004@yahoo.com>
Subject: how to access packet's data part in skbuff?
Date: Thu, 30 Dec 2004 03:54:01 -0800 (PST)
Message-ID: <20041230115401.6906.qmail@web52202.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,
          While writing kernel module packet sniffer
at IP layer,i start with first accessing packets
length 
and its data part.so, to start i try to access packet
data first and copy it to other variable to dump
its contents but i am facing a problem while accessing
the packet's data. As i have studied i 
found that data in packet at any layer resides in
between data and tail pointers.  So if i
have to print it or copy it in any unsigned string
then how to do that?
          I tried with following example which
receives only loopback packet and print data part at 
IP layer. But it does not print also why am i getting
sb->len as 1 not actual size of packet at IP layer?
regards,
linux_lover

#define MODULE
#define __KERNEL__

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/skbuff.h>
#include <linux/ip.h>
#include <linux/netfilter.h>
#include <linux/netfilter_ipv4.h>
#include <linux/myh.h>
#include <linux/string.h>

static struct nf_hook_ops nfho;
unsigned int cap_packet(unsigned int hooknum,struct
sk_buff **skb,const struct net_device *in,
                                 const struct
net_device *out,int (*okfn)(struct sk_buff *))
{
  struct sk_buff *sb = *skb;
      unsigned char *packet;
      int buflen=0,i=0;
      buflen=sb->len;
      packet=kmalloc(buflen,GFP_USER);
      memset(packet,'\0',buflen);
      printk(KERN_DEBUG "Length of sb->data in hook
function = %d\n", buflen);
      while(buflen>=0)
      {
      packet[i]=sb->data[i];
      i++;
      buflen--;
      }
      packet[i]='\0';
      strcpy(packet,sb->data);
      printk(KERN_DEBUG "packet contents of sb->data
in hook function = %s\n", packet);
      return NF_ACCEPT;

}

static int __init init(void)   
  {
              nfho.hook     = cap_packet;
              nfho.hooknum  = NF_IP_LOCAL_OUT;
              nfho.pf       = PF_INET;
              nfho.priority = NF_IP_PRI_FIRST;
              nf_register_hook(&nfho);
              return 0;
          }

static void __exit fini(void)
          {
              nf_unregister_hook(&nfho);
          }
module_init(init);
module_exit(fini);
MODULE_LICENSE("GPL");


		
__________________________________ 
Do you Yahoo!? 
The all-new My Yahoo! - What will yours do?
http://my.yahoo.com 
