From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: dev_add_pack and hardware checksumming
Date: Mon, 18 Aug 2003 05:37:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818033711.GA21360@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,
  VMware uses dev_add_pack() for capturing ethernet traffic generated
by the host and forwarding it to the guest. 

  Unfortunately skb at the packet filter input is still in CHECKSUM_HW
state, while skb->csum is relative to the skb->h.raw and 
dev_queue_xmit_nit overwrites skb->h.raw with skb->nh.raw. Due to this
I have to peek at packet body to detect protocol & its header length, 
reinitialize skb->h.raw with this knowledge and then finally do 
skb_checksum_help().

  For me it would be best if dev_queue_xmit_nit could just leave
skb->h.raw alone, usable for skb_checksum_help(), but I assume that it
is not possible due to backward compatibility? Other choice is doing
checksumming in dev_queue_xmit_nit itself, before passing skb down to
the registered packet handlers.

  BTW, it looks to me like that an uninitialized value is leaked in UDP's 
checksum field to the packets tcpdump on the host can capture...

					Thanks,
						Petr Vandrovec
						vandrove@vc.cvut.cz
