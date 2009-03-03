From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Marvell 88E609x switch?
Date: Tue, 03 Mar 2009 13:32:40 +0100
Message-ID: <1236083560.30736.114.camel@localhost.localdomain>
References: <20090227145746.GD17040@xi.wantstofly.org>
	 <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org>
	 <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org>
	 <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org>
	 <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org>
	 <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>
	 <20090227222802.GZ17040@xi.wantstofly.org>
	 <1235991382.30736.62.camel@localhost.localdomain>
	 <1235991937.30736.65.camel@localhost.localdomain>
	 <49ABF7DF.8060302@mlbassoc.com> <49ABF9A9.2040608@mlbassoc.com>
	 <Pine.LNX.4.64.0903022237580.1863@ask.diku.dk>
	 <49AC5E6F.3010204@mlbassoc.com>
	 <1236070372.30736.87.camel@localhost.localdomain>
	 <49AD1C81.1020106@mlbassoc.com>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev <netdev@vger.kernel.org>
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:55533 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbZCCMco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 07:32:44 -0500
In-Reply-To: <49AD1C81.1020106@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-03-03 at 05:03 -0700, Gary Thomas wrote:
> Jesper Dangaard Brouer wrote:
> > On Mon, 2009-03-02 at 15:32 -0700, Gary Thomas wrote:
> >> Any ideas how I might troubleshoot why packets that come
> >> into lan1.1 (port 0) aren't being pushed to the CPU port?
> > 
> > The switch supports port monitoring, with seperate ingress and egress
> > mapping, thus you could place another PC on another port and direct
> > traffic towards that, and by tcpdump inspecting ingress and egress on
> > the different physical ports... Thats how I debugged it once...
> 
> I'm a bit fuzzy on this - could you explain in a bit more detail?

You basically set the monitor destination port via REG_GLOBAL reg 0x1A
"Monitor Control".

/* Register: Monitor Control (0x1A)
   -------------------------
    bit 15:12= Ingress Monitor Dest
    bit 11:8 = Egress  Monitor Dest
    bit  7:4 = ARP Dest
    bit  3:0 = Reserved
*/

Then you configure the port register 0x08 "port control2", that this
port is to be monitored: bit5=monitor_egress and bit4=monitor_ingress.

/* Register: Port Control 2 (0x8)
   ------------------------
    bit 15    = IgnoreFSC: Force good FSC in frame
    bit 14    = VTU_prio_override   : VTU    setting overrides prio
    bit 13    = ATU_SA_prio_overrite: ATU SA setting overrides prio
    bit 12    = ATU_DA_prio_overrite: ATU DA setting overrides prio
    bit 11:10 = 802.1Q mode
     [00] = <Disabled>: use VLANtable only
     [01] = <Fallback>: fallback to VLANTable
     [10] = <Check>   : drop on miss (eq. not in VTU)
     [11] = <Secure>  : drop on miss and membership violation
    bit 9     = Discard Tagged
    bit 8     = Discard Untagged
    bit 7     = MapDA: Map using DA hits
    bit 6     = Default Forward (normal switch operation)
    bit 5     = Monitor egress
    bit 4     = Monitor ingress
    bit 3:0   = CPU port
*/


Reading through the "Monitor Control" register description, there is a
interesting description about the "ARPdest" setting... Could you try to
set it to the CPU port and see if that helps?

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
