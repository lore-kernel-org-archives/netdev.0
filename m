From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [PATCH SET][bonding] cleanup
Date: Thu, 25 Sep 2003 20:07:05 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309252007.05642.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A464EF@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <bonding-devel@lists.sourceforge.net>,
        <bonding-announce@lists.sourceforge.net>, <netdev@oss.sgi.com>,
        <linux-kernel@vger.kernel.org>, <linux-net@vger.kernel.org>,
        "Jeff Garzik" <jgarzik@pobox.com>, "Noam, Amir" <amir.noam@intel.com>,
        "Mendelson, Tsippy" <tsippy.mendelson@intel.com>,
        "Marom, Noam" <noam.marom@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jay Vosburgh" <fubar@us.ibm.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A02A464EF@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 25 September 2003 07:22 pm, Jay Vosburgh wrote:
> >patch 7 - eliminate the multicast_mode module param. settings are
> > now done only according to mode.
>
>         This goes a bit beyond straight cleanup; could you explain
> the rationale for this change?  Also, unless I'm missing something,
> the patch does not appear to update bonding.txt to reflect the fact
> that the module parameter is no more.
>
>

That question rings a bell :)
I had this discussion with Deniel Laurent on 8/30 and it sounded like 
that wouldn't be a problem after all.

[from that thread]
> Do you know that this breaks upward compatibility ?
[snip]
> But if everyone is OK ... (I'd be since I currently only use
> multicast_mode = 1 ;-).

The rationale is that the propagation code already made this module 
param obsolete, so the next step was to remove it entirely since it 
had no effect anyway.

According to the propagation RFC we sent on 2/6, multicast list, 
allmulti flag and promisc flag are all controlled the same way, and 
that is according to the USES_PRIMARY macro. When the bond uses the 
current slave as a primary interface, it, and only it, is supposed to 
have the bond's properties, while in aggregation modes all slaves 
have the same settings. There is no point in settings other slaves, 
that are not supposed to be receiving in the first place, to have 
loose filtering. Otherwise the stack will be flooded by duplicate 
packets. The situation is bad enough now since bonding has no 
solution for broadcast packets, but that's for another thread.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
