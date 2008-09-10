From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Wed, 10 Sep 2008 16:31:10 -0700
Message-ID: <6599ad830809101631q51371f75w2ab9f73ef2414f90@mail.gmail.com>
References: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com>
	 <20080910220115.GH20815@postel.suug.ch>
	 <166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com>
	 <6599ad830809101604o71b2fb82k2aca1eb0fd8ab6d8@mail.gmail.com>
	 <20080910232413.GJ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ranjit Manomohan" <ranjitm@google.com>, davem@davemloft.net,
	akpm@linux-foundation.org, kaber@trash.net, lizf@cn.fujitsu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:6878 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbYIJXb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 19:31:29 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m8ANVDX2004809
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 00:31:13 +0100
Received: from yw-out-1718.google.com (ywk9.prod.google.com [10.192.11.9])
	by zps78.corp.google.com with ESMTP id m8ANVCao003134
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 16:31:12 -0700
Received: by yw-out-1718.google.com with SMTP id 9so65426ywk.12
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 16:31:12 -0700 (PDT)
In-Reply-To: <20080910232413.GJ20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2008 at 4:24 PM, Thomas Graf <tgraf@suug.ch> wrote:
> Without a) this whole feature is very limited. It requires a process to
> be registered to the cgroup before it creates any sockets.

I think that it's a bit more flexible than that - any newly created
sockets (or newly accepted sockets) will inherit the correct classid,
so it's only existing connections that don't get reclassified.

But the common case is that applications are going to be dropped in
the correct cgroup *before* they start, via mechanisms such as pam
login modules or job-control middleware.

> Otherwise
> these sockets will not have the proper classid value and traffic from
> and to this sockets will not be classified. I don't see how this is
> practical since many applications create their sockets when the
> application is started. F.e. a web browser is causing a bulk data
> transfer, admin/user notices this and wants to put it in a restricted
> cgroup, won't work.
>

Yes, for this particular case it doesn't work. But isn't it much more
likely that the admin/user will know that web-browsers tend to trigger
bulk data transfers and configure the system so that the web browser
always starts in its own cgroup, rather than trying to jump on it
after the fact?

Paul
