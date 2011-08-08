From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [BUG] 3.0-rc1 Bridge not forwarding unicast packages
Date: Mon, 8 Aug 2011 20:02:52 +0200
Message-ID: <20110808195930@it-loops.com>
References: <20110808192646@it-loops.com>
 <20110808104803.2762dbf7@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110808104803.2762dbf7@nehalam.ftrdhcpuser.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08 Aug 11 10:48, Stephen Hemminger wrote:
> On Mon, 8 Aug 2011 19:42:19 +0200
> Michael Guntsche <mike@it-loops.com> wrote:
> 
> > Hi list,
> > 
> > I just upgraded my router/bridge combo to 3.1-rc1 from 3.0 for
> > testing. On a first look everything seemed to work fine, but when I
> > tried to connect via openvpn to my internal network (tap0 being bridged
> > with the internal network) I noticed that I was not able to access the
> > server on my internal network. I could access the bridge (which is
> > acting as the openvpn server as well) just fine though. 
> > To debug this I ran tcpdump on the openvpn client and started a ping to the
> > internal network. I could see the ARP requests being answered.
> > 
> > 19:23:49.247846 ARP, Request who-has 192.168.42.127 tell 192.168.42.96,
> > length 28
> > 19:23:49.287752 ARP, Reply 192.168.42.127 is-at 00:13:d4:4f:a2:dc,
> > length 46
> > 
> > in this case .127 is the server on the internal net and .96 the openvpn
> > client, but the icmp request did not arrive on the server. 
> > The strange thing I noticed was that I could see broadcasts packages
> > from the server on the client
> > 
> > 19:23:28.135185 IP 192.168.42.127.631 > 192.168.42.255.631: UDP, length
> > 187
> > 19:23:29.470975 IP 192.168.42.96.5353 > 224.0.0.251.5353: .......
> > 
> > but no icmp packages arrived on the server side.
> > 
> > 
> > brctl showmacs lan
> > port no mac addr                is local?       ageing timer
> >   1     00:0c:42:28:de:4e       yes                0.00
> >   2     00:0c:42:61:7f:f2       yes                0.00
> >   1     00:13:d4:4f:a2:dc       no                 0.00 <---- server on the lan side
> >   3     8e:22:41:d9:95:23       yes                0.00
> >   3     b6:e1:e3:06:c9:1a       no                 5.00 <---- client connected via tap0
> > 
> > Reverting to 3.0 solves the problem for me. I tried just reverting the bridge code on the server to the 3.0 version to make sure that it is really Bridge related, but there are too many changes outside the bridge tree so compilation fails for me.
> > 
> > If you need more information, please to not hesitate to conact me.
> > 
> > Kind regards,
> > Michael Guntsche
> 
> Do you have spanning tree enabled?
> If  so you may have a packet loop and now it is being detected.
No STP is not enabled

brctl show lan
bridge name     bridge id               STP enabled     interfaces
lan             8000.000c4228de4e       no              lan_wire
                                                        tap0
                                                        wlan0

No ebtables rules either just checked that.
Is there a way to revert just the bridge code to the 3.0 version so i can make sure it is really the bridge code, and not something else?

Kind regards,
Mike

PS: And of COURSE the subject line should be 3.1-rc1!!!! Sorry
