From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: Re: [PATCH 6/7] sock, cgroup: add sock->sk_cgroup
Date: Fri, 20 Nov 2015 12:04:05 +0100
Message-ID: <564EFE25.5000906@bmw-carit.de>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
 <1447959171-20749-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<coreteam@netfilter.org>, <cgroups@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
	<daniel@iogearbox.net>, <nhorman@tuxdriver.com>
To: Tejun Heo <tj@kernel.org>, <davem@davemloft.net>,
	<pablo@netfilter.org>, <kaber@trash.net>,
	<kadlec@blackhole.kfki.hu>, <lizefan@huawei.com>,
	<hannes@cmpxchg.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1447959171-20749-7-git-send-email-tj@kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 11/19/2015 07:52 PM, Tejun Heo wrote:
> +/*
> + * There's a theoretical window where the following accessors race with
> + * updaters and return part of the previous pointer as the prioidx or
> + * classid.  Such races are short-lived and the result isn't critical.
> + */
>  static inline u16 sock_cgroup_prioidx(struct sock_cgroup_data *skcd)
>  {
> -	return skcd->prioidx;
> +	return (skcd->is_data & 1) ? skcd->prioidx : 1;
>  }
>  
>  static inline u32 sock_cgroup_classid(struct sock_cgroup_data *skcd)
>  {
> -	return skcd->classid;
> +	return (skcd->is_data & 1) ? skcd->classid : 0;
>  }


I still try to understand what the code does, hence this stupid question:

Why is sock_cgroup_prioidx() returning 1 if is not data and
sock_cgroup_classid() a 0?

thanks,
daniel
