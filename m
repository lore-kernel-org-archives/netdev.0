From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 2/3] ipv6: per netns fib6 walkers
Date: Mon, 7 Mar 2016 16:28:26 -0800
Message-ID: <CAM_iQpXynuGx2F6RdeFcyCH7qSxPv0Q0p7etwTTje07hMSaZbw@mail.gmail.com>
References: <cover.1457085016.git.mkubecek@suse.cz>
	<6df8e224d6337b658a097ac87e72e1467cddf13d.1457085016.git.mkubecek@suse.cz>
	<CAM_iQpUxHX71GRmnmcvXpOX4P4mzJXpoYmcYhcZi2CXxEK4XFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Martin KaFai Lau <kafai@fb.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:36831 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933160AbcCHA23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 19:28:29 -0500
In-Reply-To: <CAM_iQpUxHX71GRmnmcvXpOX4P4mzJXpoYmcYhcZi2CXxEK4XFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 4:26 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Mar 4, 2016 at 2:59 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
>>  static void ipv6_route_seq_setup_walk(struct ipv6_route_iter *iter)
>>  {
>> +#ifdef CONFIG_NET_NS
>> +       struct net *net = iter->p.net;
>> +#else
>> +       struct net *net = &init_net;
>> +#endif
>> +
>
> You should pass the struct net pointer to ipv6_route_seq_setup_walk()
> instead of reading it by yourself.
>
> I don't find anyone actually using iter->p, it probably can be just removed.

Er, seq_file_net() uses it... but callers already call it.
