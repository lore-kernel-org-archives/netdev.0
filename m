From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Wed, 11 Mar 2015 14:47:30 -0700
Message-ID: <1426110450.11398.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
	 <CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
	 <1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7Pa6ypGoUr5jJfbayzwjLA-C78NOa1iPmsbmx+wXP56AA@mail.gmail.com>
	 <1426104582.11398.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M8EFF=y7LOqsiHMsT+Q1e+3wxAE93njkSk3p9nYc2gTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33915 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717AbbCKVre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 17:47:34 -0400
Received: by iecsl2 with SMTP id sl2so1055768iec.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 14:47:33 -0700 (PDT)
In-Reply-To: <CAHA+R7M8EFF=y7LOqsiHMsT+Q1e+3wxAE93njkSk3p9nYc2gTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 13:46 -0700, Cong Wang wrote:

> That is just a permission check when val > 6, given the fact most
> daemons have root permission, I doubt your argument makes a difference
> for discussion. At least with userns having root permission is more common.

Some setups use ip[6]tables rules to mangle skb->priority to select a
HTB class.

Google definitely uses this model, as netfilter code runs on multiple
cpus, while HTB classifier runs under qdisc spinlock, so far.

If you believe root user should not set skb->priority to arbitrary
values, this is a very different concern.
