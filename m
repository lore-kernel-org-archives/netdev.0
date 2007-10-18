From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 2/3] Lost locking in fl6_sock_lookup
Date: Thu, 18 Oct 2007 16:22:49 +0400
Message-ID: <47175019.4090004@openvz.org>
References: <47174950.6060409@openvz.org> <20071018.051647.23015283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59284 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756082AbXJRMW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 08:22:57 -0400
In-Reply-To: <20071018.051647.23015283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Thu, 18 Oct 2007 15:53:52 +0400
> 
>> This routine scans the ipv6_fl_list whose update is
>> protected with the socket lock and the ip6_sk_fl_lock.
>>
>> Since the socket lock is not taken in the lookup, use
>> the other one.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Applied.
> 
> But I notice that I was wrong in my email, we don't
> hold the socket lock here.
> 
> What prevents an unlink from the socket's list
> and thus a reference count of zero occurring for
> a brief moment?

Oops. You're right here :( I looked at the ip6_fl_lock
and messed it with the ip6_sk_fl_lock.

Should I resend the whole patch, or just make an 
incremental one?

Thanks,
Pavel
