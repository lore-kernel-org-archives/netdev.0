From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next v2 3/5] net_sched: act: move
 tcf_hashinfo_init() into tcf_register_action()
Date: Thu, 23 Jan 2014 16:08:59 -0800
Message-ID: <20140123160859.147c6878@nehalam.linuxnetplumber.net>
References: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
	<1390516525-8556-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:34329 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbaAXAJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:09:03 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so2495429pbb.17
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 16:09:02 -0800 (PST)
In-Reply-To: <1390516525-8556-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jan 2014 14:35:23 -0800
Cong Wang <xiyou.wangcong@gmail.com> wrote:

>  
>  struct tc_action {
>  	void			*priv;
> -	const struct tc_action_ops	*ops;
> +	struct tc_action_ops	*ops;

As much as possible all function tables should be constant.
One of the rootkit tricks is to overwrite a function table entry
at runtime. Granted tc action is a minor corner of the exposed
universe, but this seems a step backwards when the only real
gain is some refactoring/cleanup.
