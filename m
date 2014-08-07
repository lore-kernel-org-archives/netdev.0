From: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Subject: Re: Query: Is it possible  to lose interrupts between vhost and virtio_net
 during migration?
Date: Thu, 7 Aug 2014 20:47:29 +0800
Message-ID: <53E37561.5060302@huawei.com>
References: <53DA2CCC.1040606@huawei.com> <20140731143100.GA3834@redhat.com> <20140731143725.GA3875@redhat.com> <53DB705F.2000405@redhat.com> <53DB76A9.8010305@redhat.com> <53E079C8.7050700@huawei.com> <20140805094957.GB24619@redhat.com> <53E0CAA4.8010303@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, <netdev@vger.kernel.org>,
	<qinchuanyu@huawei.com>, <liuyongan@huawei.com>,
	<davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>, <kvm@vger.kernel.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <53E0CAA4.8010303@huawei.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2014/8/5 20:14, Zhangjie (HZ) wrote:
> On 2014/8/5 17:49, Michael S. Tsirkin wrote:
>> On Tue, Aug 05, 2014 at 02:29:28PM +0800, Zhangjie (HZ) wrote:
>>> Jason is right, the new order is not the cause of network unreachable.
>>> Changing order seems not work. After about 40 times, the problem occurs again.
>>> Maybe there is other hidden reasons for that.
> I modified the code to change the order myself yesterday.
> This result is about my code.
>>
>> To make sure, you tested the patch that I posted to list:
>> "vhost_net: stop guest notifiers after backend"?
>>
>> Please confirm.
>>
> OK, I will test with your patch "vhost_net: stop guest notifiers after backend".
> 
Unfortunately, after using the patch "vhost_net: stop guest notifiers after backend",
Linux VMs stopt themselves a few minutes after they were started.
>@@ -308,6 +308,12 @@ int vhost_net_start(VirtIODevice *dev, NetClientState *ncs,
>         goto err;
>     }
>
>+    r = k->set_guest_notifiers(qbus->parent, total_queues * 2, true);
>+    if (r < 0) {
>+        error_report("Error binding guest notifier: %d", -r);
>+        goto err;
>+    }
>+
>     for (i = 0; i < total_queues; i++) {
>         r = vhost_net_start_one(get_vhost_net(ncs[i].peer), dev, i * 2);
>
>@@ -316,12 +322,6 @@ int vhost_net_start(VirtIODevice *dev, NetClientState *ncs,
>         }
>     }
>
>-    r = k->set_guest_notifiers(qbus->parent, total_queues * 2, true);
>-    if (r < 0) {
>-        error_report("Error binding guest notifier: %d", -r);
>-        goto err;
>-    }
>-
>     return 0;
I wonder if k->set_guest_notifiers should be called after "hdev->started = true;" in vhost_dev_start.
-- 
Best Wishes!
Zhang Jie

