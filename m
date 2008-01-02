From: "Andy Johnson" <johnsonzjo@gmail.com>
Subject: Re: Section mismatch between 'copy_net_ns' and 'net_enable_timestamp
Date: Wed, 2 Jan 2008 17:32:25 +0200
Message-ID: <147a89290801020732n1f869b83w166a8de28f164040@mail.gmail.com>
References: <147a89290801020616g310fff86t6c8d34d32df3865a@mail.gmail.com>
	 <477B9F70.5000709@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Daniel Lezcano" <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:59414 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806AbYABPce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 10:32:34 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3174931fga.17
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2008 07:32:33 -0800 (PST)
In-Reply-To: <477B9F70.5000709@fr.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks; Well, doing it indeed avoids that error.
when I disabled the sysfs entry I had the options for network namespace
which previously was not there.
Regards,
Andy



On Jan 2, 2008 4:28 PM, Daniel Lezcano <dlezcano@fr.ibm.com> wrote:
>
> Andy Johnson wrote:
> > Hello,
> >  I had git-cloned the net-2.6.25.git tree today;
> >
> >  Then I ran "make menuconfig" and accepted the defaults without any change.
> > I want to build this tree with network namespace support.
> > I saw that in 2.6.25/net/core/net_namespace.c
> > we have some #ifdef CONFIG_NET_NS ; I did not CONFIG_NET_NS in "make
> > menuconfig".
> > So I added in net_namespace.c #define CONFIG_NET_NS, before the first
> > #ifdef CONFIG_NET_NS; then I ran make.
> >
> > I saw the following warning:
> >
> > WARNING: vmlinux.o(.text+0x1d47cd): Section mismatch: reference to .init.text:
> > (between 'copy_net_ns' and 'net_enable_timestamp')
> >
> >
> > Is there something wrong here causing this "Section mismatch"?
> > or did I do something wrong?
> >
> > Regards,
> > Andy
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
>
> Hi Andy,
>
> If you want to activate the network namespace, you should disable the
> sysfs. This is a temporary restriction until Greg-KH integrates the
> sysfs per namespace:
>
> https://lists.linux-foundation.org/pipermail/containers/2007-December/009347.html
>
> Can you try to using the menuconfig to enable the network namespace and
> check if you still have the section mismatch ?
>
> General setup
>   -> Prompt for development and/or incomplete code/drivers => enable
>   -> Configure standard kernel features => enable
>
> File systems
>   -> Pseudo filesystems
>    -> sysfs file system support => disable
>
> Networking
>   -> Networking options
>    -> Network namespace support => enable
>
> Thanks
>    -- Daniel
>
