From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: Don't call with rt6_uncached_list_flush_dev
Date: Tue, 13 Oct 2015 04:53:23 -0700 (PDT)
Message-ID: <20151013.045323.2126402747167465452.davem@davemloft.net>
References: <CACT4Y+a3J5sgSk7OvzdG6vg2PuFfBPpuJHo3csKpox5s77H+rA@mail.gmail.com>
	<1444652652.27760.158.camel@edumazet-glaptop2.roam.corp.google.com>
	<87wpusoz27.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kafai@fb.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	andreyknvl@google.com, sasha.levin@oracle.com, edumazet@google.com,
	maze@google.com, eric.dumazet@gmail.com
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wpusoz27.fsf_-_@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 12 Oct 2015 11:02:08 -0500

> 
> As originally written rt6_uncached_list_flush_dev makes no sense when
> called with dev == NULL as it attempts to flush all uncached routes
> regardless of network namespace when dev == NULL.  Which is simply
> incorrect behavior.
> 
> Furthermore at the point rt6_ifdown is called with dev == NULL no more
> network devices exist in the network namespace so even if the code in
> rt6_uncached_list_flush_dev were to attempt something sensible it
> would be meaningless.
> 
> Therefore remove support in rt6_uncached_list_flush_dev for handling
> network devices where dev == NULL, and only call rt6_uncached_list_flush_dev
>  when rt6_ifdown is called with a network device.
> 
> Fixes: 8d0b94afdca8 ("ipv6: Keep track of DST_NOCACHE routes in case of iface down/unregister")
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied and queued up for -stable, thanks.
