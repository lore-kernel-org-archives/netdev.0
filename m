From: Thomas Spatzier <thomas.spatzier@de.ibm.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Tue, 14 Dec 2004 08:40:26 +0100
Message-ID: <OF818F5ECF.239B7010-ONC1256F6A.0029BA10-C1256F6A.002A27C3@de.ibm.com>
References: <Pine.LNX.4.61.0412101536160.16016@hibernia.jakma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: hadi@cyberus.ca, Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.61.0412101536160.16016@hibernia.jakma.org>
To: Paul Jakma <paul@clubi.ie>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Paul Jakma <paul@clubi.ie> wrote on 10.12.2004 16:37:15:
> Thomas' original patch was to address this problem. I wonder could he
> recap the kernel side of this problem?

Here is why we submitted the original patch: We got reports from
several customers that their dynamic routing daemons got hung when
one network interface lost its physical connection. Some debugging
showed that the write queues of sockets went full and got blocked.
This was because we issued a netif_stop_queue when we detect a
cable pull or something.
As a solution, we removed the netif_stop_queue calls and just dropped
the packets + we increment the respective error counts in the
net_device_stats and call netif_carrier_off.
This solved the customer problems and seems to be right thing for
zebra etc.

Regards,
Thomas.
