From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: fix dev refcont leak when DAD failed
Date: Tue, 06 Sep 2016 14:19:11 -0700 (PDT)
Message-ID: <20160906.141911.690861946963563376.davem@davemloft.net>
References: <1473062791-21118-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        dingtianhong@huawei.com, netdev@vger.kernel.org,
        stable@vger.kernel.org
To: weiyongjun1@huawei.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1473062791-21118-1-git-send-email-weiyongjun1@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <weiyongjun1@huawei.com>
Date: Mon, 5 Sep 2016 16:06:31 +0800

> In general, when DAD detected IPv6 duplicate address, ifp->state
> will be set to INET6_IFADDR_STATE_ERRDAD and DAD is stopped by a
> delayed work, the call tree should be like this:
> 
> ndisc_recv_ns
>   -> addrconf_dad_failure        <- missing ifp put
>      -> addrconf_mod_dad_work
>        -> schedule addrconf_dad_work()
>          -> addrconf_dad_stop()  <- missing ifp hold before call it
> 
> addrconf_dad_failure() called with ifp refcont holding but not put.
> addrconf_dad_work() call addrconf_dad_stop() without extra holding
> refcount. This will not cause any issue normally.
> 
> But the race between addrconf_dad_failure() and addrconf_dad_work()
> may cause ifp refcount leak and netdevice can not be unregister,
> dmesg show the following messages:
> 
> IPv6: eth0: IPv6 duplicate address fe80::XX:XXXX:XXXX:XX detected!
> ...
> unregister_netdevice: waiting for eth0 to become free. Usage count = 1
> 
> Cc: stable@vger.kernel.org
> Fixes: c15b1ccadb32 ("ipv6: move DAD and addrconf_verify processing
> to workqueue")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied and queued up for -stable.
