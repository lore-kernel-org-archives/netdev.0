From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH 2/2] netpoll: Don't poll for received packets
Date: Wed, 12 Mar 2014 11:39:49 -0700
Message-ID: <CAM_iQpVRkHR7_coMDUSLkVmhAgbO==b4BVPuKTMpKz+SRz=WjA@mail.gmail.com>
References: <871ty9qvaf.fsf_-_@xmission.com>
	<87vbvlpgnk.fsf_-_@xmission.com>
	<1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311.004217.1616529960369263682.davem@davemloft.net>
	<1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<87a9cxf7mp.fsf_-_@xmission.com>
	<87wqg1dsyw.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Satyam Sharma <satyam.sharma@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:57199 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390AbaCLSju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 14:39:50 -0400
Received: by mail-oa0-f53.google.com with SMTP id j17so10583543oag.12
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 11:39:49 -0700 (PDT)
In-Reply-To: <87wqg1dsyw.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 1:45 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> -       work = napi->poll(napi, budget);
> -       trace_napi_poll(napi);
> +       /* Use a budget of 0 to request the drivers not process
> +        * their receive queue.  Warn when they do anyway.
> +        */
> +       work = napi->poll(napi, 0);
> +       WARN_ON_ONCE(work != 0);
>

Adding more printk's in netpoll call path would only bring more troubles.
