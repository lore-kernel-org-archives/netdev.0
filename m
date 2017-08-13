From: David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Sun, 13 Aug 2017 17:08:03 -0600
Message-ID: <5a4e7562-49f7-a91f-5776-5a0efe9161c7@gmail.com>
References: <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
 <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
 <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg@mail.gmail.com>
 <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com>
 <CAEA6p_AOcNkAWPc7NFBnr8QWi3eHdJiQ2=8D_DB_XthwSDL2+Q@mail.gmail.com>
 <CALAqxLUoV6EQvofTEv9whW1_QMPBPU7eJBhRFUjaSs7CGeRFww@mail.gmail.com>
 <CAM_iQpWMWg5ytDq2Y9p9uet1zowGuCX+eksyiyxu9vQ18WoPxQ@mail.gmail.com>
 <CAEA6p_CooRGNOQN3fosF0JLqmd9aOTuNHKNPE8cbrzDH6c176w@mail.gmail.com>
 <CAEA6p_COwXWP97wSHvzokmm8ckQ2QEd7=dfNH04ttDPm_z3bcg@mail.gmail.com>
 <20170812180129.GA31700@splinter>
 <CAEA6p_Cngs9Nx9OZ15oRMu_43oZTYHjzcw2vzgemfEyh_g0nNA@mail.gmail.com>
 <61d95fe2-edfd-9fc4-5e21-5b96e4e03c9f@gmail.com>
 <CAEA6p_BtBdPviFVRC4UoJchbz7eH9fM=KDihYA3zUQebmNBpdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ido Schimmel <idosch-2h5rdk4LcBEdnm+yROfE0A@public.gmane.org>,
        Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>,
        lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux USB List <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Felipe Balbi <felipe.balbi-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Wei Wang <weiwan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAEA6p_BtBdPviFVRC4UoJchbz7eH9fM=KDihYA3zUQebmNBpdA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 8/13/17 2:56 PM, Wei Wang wrote:
>> Looking at my patch to move host routes from loopback to device with the
>> address, I have this:
>>
>> @@ -2789,7 +2808,8 @@ static int fib6_ifdown(struct rt6_info *rt, void *arg)
>>         const struct arg_dev_net *adn = arg;
>>         const struct net_device *dev = adn->dev;
>>
>> -       if ((rt->dst.dev == dev || !dev) &&
>> +       if ((rt->dst.dev == dev || !dev ||
>> +            (netdev_unregistering(dev) && rt->rt6i_idev->dev == dev)) &&
>>             rt != adn->net->ipv6.ip6_null_entry &&
>>             (rt->rt6i_nsiblings == 0 ||
>>              (dev && netdev_unregistering(dev)) ||
> 
> As you explained earlier, after your patch, all entries in the fib6
> tree will have rt->dst.dev be the same as rt->rt6i_idev->dev except
> those ones created by p6_rt_cache_alloc() and ip6_rt_pcpu_alloc().
> Then the above newly added check is mainly to catch those cached dst
> entries (created by ip6_rt_cached_alloc()). right?
> And it is required because __ipv6_ifa_notify() -> ip6_del_rt() won't
> take care of those cached dst entries.
> 
> Then I think I should wait for your patches to get merged before
> submitting my patch?

no. your patch will need to go back to 4.12; my changes will not be
appropriate for that.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
