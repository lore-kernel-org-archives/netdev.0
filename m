From: Cong Wang <cwang@twopensource.com>
Subject: Re: VLAN creation may lead to deadlock.
Date: Fri, 13 Feb 2015 11:54:25 -0800
Message-ID: <CAHA+R7Nk2SeM-Zga4qzrg_4teBUFmVcS=im1JMmF9CjA2nsjMQ@mail.gmail.com>
References: <20150213120217.GA6198@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Ignacy Gawedzki <ignacy.gawedzki@green-communications.fr>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34887 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbbBMTy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 14:54:26 -0500
Received: by iecrl12 with SMTP id rl12so19731909iec.2
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 11:54:25 -0800 (PST)
In-Reply-To: <20150213120217.GA6198@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 13, 2015 at 4:02 AM, Ignacy Gawedzki
<ignacy.gawedzki@green-communications.fr> wrote:
> Hi,
>
> I stumbled upon the following annoying situation: supposing eth0 is some
> interface that is currently DOWN, the following command
>
>   ip link add link eth0 name eth0.1 up type vlan id 1
>
> never returns and the kernel printks the following lines every few seconds
>
>   unregister_netdevice: waiting for eth0.1 to become free. Usage count = 2
>
> I understand that the kernel should prevent me from creating a VLAN interface
> that's initially up when loose-binding is off and the master interface is down
> (and indeed there is absolutely no problem when loose-binding is on), but the
> unregistering of the currently-being-registered device should not block like
> that.  It appears there are too few dev_puts compared to dev_holds in there.

Good catch! It looks like we forgot to call unregister_vlan_dev(),
I am cooking a patch.
