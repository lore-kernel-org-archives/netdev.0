From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Mystery packet killing tg3
Date: Wed, 04 May 2005 15:30:22 -0700
Message-ID: <1115245822.15156.78.camel@rh4>
References: <B1508D50A0692F42B217C22C02D84972020F3EB2@NT-IRVA-0741.brcm.ad.broadcom.com>
 <20050504155143.1a78cb7a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20050504155143.1a78cb7a@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-05-04 at 15:51 -0700, Stephen Hemminger wrote:
> On Tue, 3 May 2005 23:27:38 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
> 
> > I think stop_block errors can only happen during dev_close, suspend, netdev
> > watchdog, or ethtool "set" calls.
> 
> It seems that dhclient was failing on bootup then taking the device down.
> When the device down happened it got the tg3_stop_block from
>  Call Trace:<ffffffff880178a9>{:tg3:tg3_stop_block+185} <ffffffff88017b1d>{:tg3:tg3_abort_hw+605}
>        <ffffffff88018178>{:tg3:tg3_halt+40} <ffffffff88019827>{:tg3:tg3_close+71}
>        <ffffffff802c1734>{dev_close+100} <ffffffff802c2b68>{dev_change_flags+104}
>        <ffffffff80300e35>{devinet_ioctl+773} <ffffffff803022dc>{inet_ioctl+92}
>        <ffffffff802b82bc>{sock_ioctl+556} <ffffffff801898fa>{do_ioctl+58}
>        <ffffffff80189c2b>{vfs_ioctl+715} <ffffffff80189cad>{sys_ioctl+77}
>        <ffffffff8010ea66>{system_call+126} 
> 

This makes sense. Before the dhclient closes the device, was the device
functioning properly? If not, was it not sending or not receiving?

If the device was functioning properly prior to the close, meaning that
the dhclient was closing because there was no response from the dhcp
server, then the stop_block error was inconsequential.
