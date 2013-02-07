From: Andy Grover <agrover@redhat.com>
Subject: Re: IP_FREEBIND and binding to in-use addr:ports
Date: Thu, 07 Feb 2013 10:42:46 -0800
Message-ID: <5113F5A6.80500@redhat.com>
References: <5112F998.8050605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: target-devel <target-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55001 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756684Ab3BGSmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 13:42:47 -0500
In-Reply-To: <5112F998.8050605@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2013 04:47 PM, Andy Grover wrote:
> OK, this is weird:
>
> https://bugzilla.redhat.com/show_bug.cgi?id=908368
>
> It appears you can listen on the same address:port if you do it from a
> different iscsi target, or even a different tpg (so there are no
> configfs name collisions). I believe this is because we are setting
> IP_FREEBIND sockopt, so we can configure listening on iscsi portals (aka
> ip:port) before the IP is assigned.
>
> from ip(7):
> IP_FREEBIND (since Linux 2.4)
> If enabled, this boolean option allows binding to an IP address that is
> nonlocal or does not (yet) exist.  This permits listening on a socket,
> without requiring the underlying network interface or the specified
> dynamic IP address to be up at the time that the application is trying
> to bind to it.  This option is the per-socket equivalent of the
> ip_nonlocal_bind /proc interface described below.
>
> This doesn't say anything about if the address:port is already in use.
> Dave/netdev, should the network stack be returning an error when
> attempting to bind to an address:port already in use even if IP_FREEBIND
> is set, or should the caller be checking for this before trying to
> kernel_bind()?
>
> Or is something else the issue?

Looks like IP_FREEBIND doesn't make a difference. More shortly. -- Andy
