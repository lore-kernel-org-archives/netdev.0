From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] tcp: SO_TIMESTAMP implementation for TCP
Date: Fri, 30 Apr 2010 22:31:43 -0700
Message-ID: <AANLkTinyuDjE75ZkQlre7FSC4vR2M4_56XcBF5oXwogU@mail.gmail.com>
References: <alpine.DEB.1.00.1004292246440.12776@pokey.mtv.corp.google.com>
	 <20100429.233958.212393607.davem@davemloft.net>
	 <i2i65634d661004300058s5ee1b177oee249d3d22baad62@mail.gmail.com>
	 <20100430.164115.257514715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:17674 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037Ab0EAFbq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 01:31:46 -0400
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o415Vj6p002660
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 22:31:45 -0700
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by wpaz13.hot.corp.google.com with ESMTP id o415Vhhb025343
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 22:31:44 -0700
Received: by pvg3 with SMTP id 3so489654pvg.27
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 22:31:43 -0700 (PDT)
In-Reply-To: <20100430.164115.257514715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I don't see an nice way to do that, we're profiling a significant
>> percentage of millions of connections over thousands of paths as par=
t
>> of standard operations while incurring negligible overhead. =A0The a=
pp
>> can can easily timestamp its operations, but without some mechanism
>> for getting timestamps out of a TCP connection, the networking porti=
on
>> of servicing requests is pretty much a black box in that.
>
> If other people have an opinion about this, now would be the time
> to speak up. :-)
>
The use case that motivated this patch is really the same as that of
UDP in that application is receiving messages that it wants to to time
stamp; in the case of TCP the application extracts the frames out of
the stream.  The lack of a timestamp to discern when a message was
received over TCP is readily apparent when designing a message based
ULP that can dynamically select which protocol to run over.
