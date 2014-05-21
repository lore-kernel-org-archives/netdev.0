From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: Default network namespace name
Date: Wed, 21 May 2014 11:44:13 +0200
Message-ID: <537C756D.4070407@6wind.com>
References: <alpine.BSF.2.00.1405210826570.47766@nic-i.leissner.se>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Peter Fassberg <pf@leissner.se>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:47555 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbaEUJoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 05:44:16 -0400
Received: by mail-we0-f175.google.com with SMTP id t61so1731631wes.6
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 02:44:14 -0700 (PDT)
In-Reply-To: <alpine.BSF.2.00.1405210826570.47766@nic-i.leissner.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/05/2014 08:36, Peter Fassberg a =E9crit :
>
> Hi!
>
> Is there a name of the default network namespace?
No.

>
> I would like to execute a command in the default network namespace wh=
ile running
> a shell in a non-default namespace.
>
> Like this: ip netns exec "" ip link
> Or this:   ip netns exec . ip link
>
> That command end up with a mis-spelled error message: :)
> seting the network namespace "" failed: Invalid argument

You can try something like this (I suppose that init runs in your
"default network namespace") :

ip netns add foo (just to create /var/run/netns which is a tmpfs)
ip netns del foo
touch /var/run/netns/default
mount --bind /proc/1/ns/net /var/run/netns/default
ip netns exec default ip link

Regards,
Nicolas
