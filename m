From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 16:27:24 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com>
References: <41912F7A.6000408@redhat.com> <200412161153.51251.hasso@estpak.ee>
 <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com>
 <200412161302.42357.hasso@estpak.ee> <41C2F6E5.5010607@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Hasso Tepper <hasso@estpak.ee>,
	Harald Welte <laforge@gnumonks.org>,
	Neil Horman <nhorman@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Andrea G Forte <andreaf@cs.columbia.edu>
In-Reply-To: <41C2F6E5.5010607@cs.columbia.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Dec 2004, Andrea G Forte wrote:

> Yes, using the same concept used in Junos would make things much easier. On 
> top of this, when I change the primary IP, it takes about 500ms to see the 
> change applied which is critical for real time applications. Using more than 
> one primary IP would solve this as well.

> Also it seems that if I have a primary address and a secondary one (alias), 
> even though I make the primary address invalid (trying to force the kernel to 
> use the secondary first), the kernel still tries the primary first regardless 
> of its validity (I set the primary IP to  0.0.0.0).

Which source IP is used by the kernel is determined primary by your 
routing tables.

The requirements for an IP address to be allowed to be used in the 
routing table is that the IP address does exists on any of your 
interfaces, either as primary or secondary.

When you add/delete a primary address to a interface the kernel 
automatically adds/deletes routes accordingly, including source IP address 
selection.

If the routing table does not have information about which source IP 
address to use for this traffic then the kernel searches the interface for 
a valid primary address.

Regards
Henrik
