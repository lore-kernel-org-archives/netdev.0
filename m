From: Cong Wang <cwang@twopensource.com>
Subject: Re: Activate netns
Date: Thu, 27 Mar 2014 09:34:34 -0700
Message-ID: <CAHA+R7M_D49aVjOd85MTpjhBgcYTOZALAnU7y7N6T17mDrP0bw@mail.gmail.com>
References: <alpine.BSF.2.00.1403271539380.78113@nic-i.leissner.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Peter Fassberg <pf@leissner.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:38068 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbaC0Qef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:34:35 -0400
Received: by mail-la0-f52.google.com with SMTP id ec20so2788611lab.39
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:34:34 -0700 (PDT)
In-Reply-To: <alpine.BSF.2.00.1403271539380.78113@nic-i.leissner.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2014 at 7:51 AM, Peter Fassberg <pf@leissner.se> wrote:
>
> Hi!
>
> I have trouble to activate netns on OpenWrt with kernel 3.8.13.
>
> I get this:
>
> root@ROOter:~# ip netns show
> root@ROOter:~# ip netns add blue
> Failed to create a new network namespace "blue": Invalid argument

Basically, `ip netns add blue` creates a file named "blue" in /var/run/netns/
and then binds mount it with /proc/self/ns/net so that this netns could
be held outside.

Try to strace ip netns add to see if setns() fails, which is likely caused
by the lack of netns support of your kernel.
