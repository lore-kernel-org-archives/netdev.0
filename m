From: Jeff Garzik <jgarzik@pobox.com>
Subject: double-check me?
Date: Sun, 17 Aug 2003 13:45:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F3FBF50.8070207@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Maybe you guys can spot something I'm missing here.  alloc_netdev is 
supposed to guarantee that dev->priv is aligned by 32 bytes:

struct net_device *alloc_netdev(int sizeof_priv, const char *mask,
                                        void (*setup)(struct net_device *))
{
         struct net_device *dev;
         int alloc_size;

         /* ensure 32-byte alignment of the private area */
         alloc_size = sizeof (*dev) + sizeof_priv + 31;

         dev = (struct net_device *) kmalloc (alloc_size, GFP_KERNEL);
         if (dev == NULL)
         {
                 printk(KERN_ERR "alloc_dev: Unable to allocate device 
memory.\n"
);
                 return NULL;
         }

         memset(dev, 0, alloc_size);

         if (sizeof_priv)
                 dev->priv = (void *) (((long)(dev + 1) + 31) & ~31);


Now... shouldn't that last line of code be "dev + 1 + sizeof(*dev)" ?

It seems to work 2.[456] for a long time, so I am doubting myself... 
surely it would have caused memory corruption or something by now if I 
have really found a bug.

	Jeff
