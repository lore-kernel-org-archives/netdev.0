From: Andre Correa <andre.correa@pobox.com>
Subject: nf_unregister_hook crashing kernel
Date: Thu, 22 Apr 2004 17:51:06 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4088303A.2080208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi list, I'm playing with a module that uses netfilter hooks. It 
register using nf_register_hook without problems, but when I try 
nf_unregister_hook in my "cleanup" function the kernel crashs. I've 
found that it crashs calling nf_unregister_hook, but have no idea how to 
debug it further...

Here goes some snips from my code. Nothing new. I've searched other 
modules and found that everybody makes the same.


...<snip>...

static nf_hookfn my_nf_hook;
 

static struct nf_hook_ops my_ingress_ipv4 = {
        .hook           = my_nf_hook,
        .owner          = THIS_MODULE,
        .pf             = PF_INET,
        .hooknum        = NF_IP_PRE_ROUTING,
        .priority       = NF_IP_PRI_MANGLE + 1
};

...<snip>...

static unsigned int my_nf_hook(unsigned int hook, struct sk_buff **pskb,
                   const struct net_device *indev,
                   const struct net_device *outdev,
                   int (*okfn)(struct sk_buff *))
{
        if ((*pskb)->my_flags & MY_F_ENQUEUE)
                return NF_QUEUE;
 

        return NF_ACCEPT;
}

...<snip>...

static int __init my_init_hooks(void)
{
        int err;
 

        if ((err = nf_register_queue_handler(PF_INET, my_nf_queue, NULL)))
                return err;
}

...<snip>....

static void __exit my_unhook(void)
{

       nf_unregister_hook(&my_ingress_ipv4);
}

...<snip>...

module_init(my_init_module);
module_exit(my_cleanup_module);
MODULE_LICENSE("GPL");


Like I said, nothing new. Is there anybody who can give me some info on 
how/when can nf_unregister_hook crash the kernel? How can I debug some 
more?!

Tks in advance for any help.

Andre
