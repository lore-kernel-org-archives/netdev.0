From: Sam Leffler <sam@errno.com>
Subject: Re: ethernet QoS support?
Date: Fri, 9 Jul 2004 15:34:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407091534.53166.sam@errno.com>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com> <1089383622.1030.21.camel@jzny.localdomain> <200407092126.43021.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca, Jeff Garzik <jgarzik@pobox.com>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200407092126.43021.vkondra@mail.ru>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 09 July 2004 11:26 am, Vladimir Kondratiev wrote:

> > So what do you do now?
>
> Waiting. If no support will exist, it simply means we will be unable to use
> QoS provided by modern 802.11. Depending on market development, impact may
> range from being slightly slower relating to Windows clients, to being
> almost completely unable to communicate for traffic like VOIP. Later will
> be the case if most access points will implement QoS as in TGE.
>
> I can now deliver packets accordingly to skb->priority, but if stack have
> different idea for what is proper proportion between different sorts of
> traffic, driver's Tx path will be flooded with low priority frames.
>
> Situation is much worser for streams with admission control. I have no
> mechanism to communicate with stack for such traffic establishment and tear
> down.

FWIW the madwifi net80211 layer parses TOS to calculate priority and sticks it 
in the skb.  It also calculates the WME AC to form the QoS frame matter.  
This is then handed to drivers below.  The Atheros driver supports multiple 
tx queues in h/w with appropriate scheduling (for 5212 MACs); it uses the AC 
to set packets on the appropriate queue.

Clearly it'd be better if upper layers did the TOS stuff.  Whatever is done 
however should consider the case where the driver (nee h/w) has it's own 
queueing/scheduling facilities.

	Sam
