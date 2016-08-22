From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH 0/5] Make /sys/class/net per net namespace objects belong
 to container
Date: Mon, 22 Aug 2016 09:24:26 -0700
Message-ID: <20160822162426.GA12277@dtor-ws>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
 <20160821.234139.1856651235617174329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tj@kernel.org, ebiederm@xmission.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160821.234139.1856651235617174329.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 21, 2016 at 11:41:39PM -0700, David Miller wrote:
> From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> Date: Tue, 16 Aug 2016 15:33:10 -0700
> 
> > There are objects in /sys hierarchy (/sys/class/net/) that logically belong
> > to a namespace/container. Unfortunately all sysfs objects start their life
> > belonging to global root, and while we could change ownership manually,
> > keeping tracks of all objects that come and go is cumbersome. It would
> > be better if kernel created them using correct uid/gid from the beginning.
> > 
> > This series changes kernfs to allow creating object's with arbitrary
> > uid/gid, adds get_ownership() callback to ktype structure so subsystems
> > could supply their own logic (likely tied to namespace support) for
> > determining ownership of kobjects, and adjusts sysfs code to make use of
> > this information. Lastly net-sysfs is adjusted to make sure that objects in
> > net namespace are owned by the root user from the owning user namespace.
> > 
> > Note that we do not adjust ownership of objects moved into a new namespace
> > (as when moving a network device into a container) as userspace can easily
> > do it.
> 
> As shown by the kbuild robot, this fails to build when CONFIG_SYSFS
> it disabled.

Sorry about that, I haven't noticed that all netdev queue stuff is
protected by #ifdef CONFIG_SYSFS. I'll move the definition out and
resubmit in a few days (maybe Eric and Tejun will have some comments for
be by then as well...).

Thanks.

-- 
Dmitry
