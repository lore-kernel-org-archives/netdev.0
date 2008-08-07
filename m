From: "Tom Herbert" <therbert@google.com>
Subject: Re: SO_REUSEPORT?
Date: Thu, 7 Aug 2008 10:58:22 -0700
Message-ID: <65634d660808071058k7eb33330tcf3c7a877b7a64d@mail.gmail.com>
References: <65634d660808070957j12e1f93rfb577efabc771c9a@mail.gmail.com>
	 <200808072009.34891.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:36645 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbYHGR6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 13:58:34 -0400
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out3.google.com with ESMTP id m77HwO3w022424
	for <netdev@vger.kernel.org>; Thu, 7 Aug 2008 18:58:24 +0100
Received: from rv-out-0506.google.com (rvbk40.prod.google.com [10.140.87.40])
	by zps18.corp.google.com with ESMTP id m77HwNE8025350
	for <netdev@vger.kernel.org>; Thu, 7 Aug 2008 10:58:23 -0700
Received: by rv-out-0506.google.com with SMTP id k40so470521rvb.57
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 10:58:23 -0700 (PDT)
In-Reply-To: <200808072009.34891.rdenis@simphalempin.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > We are looking at ways to scale TCP listeners.  I think we like is the
> > ability to listen on a port from multiple threads (sockets bound to
> > same port,  INADDR_ANY, and no interface binding) , which is what
> > SO_REUSEPORT would seem to allow.  Has this ever been implemented for
> > Linux or is there a good reason not to have it?
>
> On Linux, SO_REUSEADDR provide most of what SO_REUSEPORT provides on BSD.
>
> In any case, there is absolutely no point in creating multiple TCP listeners.
> Multiple threads can accept() on the same listener - at the same time.
>

We've been doing that, but then on wakeup it would seem that we're at
the mercy of scheduling-- basically which ever threads wakes up first
will get to process accept queue first.  This seems to bias towards
threads running on the same CPU as the wakeup is called, and   so this
method doesn't give us an even distribution of new connections across
the threads that we'd like.

Tom
