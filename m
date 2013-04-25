From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/4] net/cpsw: make sure modules remove does not leak
 any ressources
Date: Thu, 25 Apr 2013 16:47:13 +0400
Message-ID: <517925D1.2030509@cogentembedded.com>
References: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de> <1366829305-9752-3-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>, tglx@linutronix.de,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:33062 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab3DYMs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 08:48:28 -0400
Received: by mail-la0-f49.google.com with SMTP id fp13so320524lab.22
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 05:48:27 -0700 (PDT)
In-Reply-To: <1366829305-9752-3-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 24-04-2013 22:48, Sebastian Andrzej Siewior wrote:

> This driver does not clean up properly after leaving. Here is a list:
> - Use unregister_netdev(). free_netdev() is good but not enough
> - Use the above also on the other ndev in case of dual mac
> - Free data.slave_data. The name of the strucre makes it look like

    s/strucre/structure/

>    it is platform_data but it is not. It is just a trick!
> - Free all irqs. Again: freeing one irq is good start, but freeing all
>    of them is better.

> With this rmmod & modprobe of cpsw seems to work. The remaining issue
> is:
> |WARNING: at fs/sysfs/dir.c:536 sysfs_add_one+0x9c/0xd4()
> |sysfs: cannot create duplicate filename '/devices/ocp.2/4a100000.ethernet/4a101000.mdio'
> |WARNING: at lib/kobject.c:196 kobject_add_internal+0x1a4/0x1c8()

> comming from of_platform_populate() and I am not sure that this belongs
> here.

> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

WBR, Sergei
