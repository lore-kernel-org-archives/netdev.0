From: Shirley Ma <mashirle@us.ibm.com>
Subject: virtio_net: remove recv refill work?
Date: Thu, 10 Mar 2011 13:03:58 -0800
Message-ID: <1299791038.25664.213.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Rusty,

What's the reason to use refill work in receiving path? 

static void refill_work(struct work_struct *work)
{
        struct virtnet_info *vi;
        bool still_empty;

        vi = container_of(work, struct virtnet_info, refill.work);
        napi_disable(&vi->napi);
        still_empty = !try_fill_recv(vi, GFP_KERNEL);
        napi_enable(&vi->napi);

        /* In theory, this can happen: if we don't get any buffers in
         * we will *never* try to fill again. */
        if (still_empty)
                schedule_delayed_work(&vi->refill, HZ/2);
}

It looks more expensive than only refilling the buffers in recv path. It
could cause more guest exits, maybe more RX interrupts. Can we move the
refill work in recv path only?

If we can remove it, I will run some test to compare the difference with
the change.

Thanks
Shirley



