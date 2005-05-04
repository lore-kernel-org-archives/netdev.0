From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Mystery packet killing tg3
Date: Wed, 4 May 2005 15:51:43 -0700
Message-ID: <20050504155143.1a78cb7a@dxpl.pdx.osdl.net>
References: <B1508D50A0692F42B217C22C02D84972020F3EB2@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3EB2@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 May 2005 23:27:38 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> Stephen Hemminger wrote:
> 
> > Initially, it reproduced everytime link came up, we 
> > reconfigured the VLAN to
> > have a mirror port into a laptop to try and capture what was 
> > happening, but when
> > we did that the bootup problem went away. It was in the tg3_reset_hw
> > during initial dev_open.
> > 
> 
> During initial dev_open, the TG3_FLAG_INIT_COMPLETE flag is not set so
> tg3_reset_hw() should not call tg3_abort_hw() where the stop_block calls are
> made. So there should be no stop_block errors.
> 
> I think stop_block errors can only happen during dev_close, suspend, netdev
> watchdog, or ethtool "set" calls.

It seems that dhclient was failing on bootup then taking the device down.
When the device down happened it got the tg3_stop_block from
 Call Trace:<ffffffff880178a9>{:tg3:tg3_stop_block+185} <ffffffff88017b1d>{:tg3:tg3_abort_hw+605}
       <ffffffff88018178>{:tg3:tg3_halt+40} <ffffffff88019827>{:tg3:tg3_close+71}
       <ffffffff802c1734>{dev_close+100} <ffffffff802c2b68>{dev_change_flags+104}
       <ffffffff80300e35>{devinet_ioctl+773} <ffffffff803022dc>{inet_ioctl+92}
       <ffffffff802b82bc>{sock_ioctl+556} <ffffffff801898fa>{do_ioctl+58}
       <ffffffff80189c2b>{vfs_ioctl+715} <ffffffff80189cad>{sys_ioctl+77}
       <ffffffff8010ea66>{system_call+126} 
