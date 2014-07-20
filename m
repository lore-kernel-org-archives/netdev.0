From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next] net: print a notification on device rename
Date: Sun, 20 Jul 2014 12:37:52 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B01758@avmb3.qlogic.org>
References: <1405622012-5511-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Laight <David.Laight@ACULAB.COM>
To: Veaceslav Falico <vfalico@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:29361 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751485AbaGTMiI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2014 08:38:08 -0400
In-Reply-To: <1405622012-5511-1-git-send-email-vfalico@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Currently it's done silently (from the kernel part), and thus it might be hard to
> track the renames from logs.
>
> Add a simple netdev_info() to notify the rename, but only in case the previous
> name was valid.

Hi,

Why you're at it, perhaps we could also consider adding an optional ndo callback
in the drivers to notify them of the device name change?
[e.g., multi-module dependencies where one would wish to inform the others
of the name change]

Cheers,
Yuval

>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Vlad Yasevich <vyasevic@redhat.com>
> CC: stephen hemminger <stephen@networkplumber.org>
> CC: Jerry Chu <hkchu@google.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
> CC: David Laight <David.Laight@ACULAB.COM>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
> ---
>  net/core/dev.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/core/dev.c b/net/core/dev.c index 239722a..d14ebf0 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1113,6 +1113,9 @@ int dev_change_name(struct net_device *dev, const
> char *newname)
>               return err;
>       }
>
> +     if (oldname[0] && !strchr(oldname, '%'))
> +             netdev_info(dev, "renamed from %s\n", oldname);
> +
>       old_assign_type = dev->name_assign_type;
>       dev->name_assign_type = NET_NAME_RENAMED;
>

________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
