From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 15 Dec 2004 08:50:27 -0500
Message-ID: <1103118626.1076.53.camel@jzny.localdomain>
References: <OF818F5ECF.239B7010-ONC1256F6A.0029BA10-C1256F6A.002A27C3@de.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Jakma <paul@clubi.ie>, Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, jgarzik@pobox.com,
        netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Spatzier <thomas.spatzier@de.ibm.com>
In-Reply-To: <OF818F5ECF.239B7010-ONC1256F6A.0029BA10-C1256F6A.002A27C3@de.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-14 at 02:40, Thomas Spatzier wrote:
> 
> 
> Paul Jakma <paul@clubi.ie> wrote on 10.12.2004 16:37:15:
> > Thomas' original patch was to address this problem. I wonder could he
> > recap the kernel side of this problem?
> 
> Here is why we submitted the original patch: We got reports from
> several customers that their dynamic routing daemons got hung when
> one network interface lost its physical connection. Some debugging
> showed that the write queues of sockets went full and got blocked.
> This was because we issued a netif_stop_queue when we detect a
> cable pull or something.

I did some more thinking in the background and i wish to change my
opinion. What you see is Very Odd. I think there may be a bug upstream
at the socket layer or even before that - but doesnt sound like a device
level bug. Wasnt someone supposed to send a small proggie to Herbert?
When you netif_stop_queue you should never receive packets anymore
at the device level. If you receive any its a bug and you should drop
them and bitch violently. In other words i think what you have at the
moment is bandaid not the solution.

> As a solution, we removed the netif_stop_queue calls and just dropped
> the packets + we increment the respective error counts in the
> net_device_stats and call netif_carrier_off.
> This solved the customer problems and seems to be right thing for
> zebra etc.

We need to Fix this issue. Either your driver is doing something wrong
or something is broken upstackstream.
Can you describe how your driver uses the netif_start/stop/wake
interfaces?
Whoever promised to send that program to Herbert - please do.

cheers,
jamal
