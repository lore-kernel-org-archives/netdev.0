From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: Question regarding protocol specific mtu for FCoE
Date: Wed, 3 Jun 2009 14:17:21 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0906031407190.5072@ppwaskie-MOBL2.amr.corp.intel.com>
References: <7C88852EF6F99F4EB538472FCFEBE2223A7E6F45@orsmsx509.amr.corp.intel.com>
 <4A26BAF7.3070301@hp.com> <7C88852EF6F99F4EB538472FCFEBE2223A7E6FBD@orsmsx509.amr.corp.intel.com>
 <4A26E4AE.4020607@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Zou, Yi" <yi.zou@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Dev, Vasu" <vasu.dev@intel.com>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"Ma, Steve" <steve.ma@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4A26E4AE.4020607@hp.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 1) the "HW MTU" used by the NIC and the guts of the driver
> 2) the legacy networking (eg IP etc) MTU passed up through the legacy path
> 3) the fcoe MTU passed up through the fcoe path
> 
> where 1 is the max of 2,3

Whatever is decided to do is going to be targeted at ixgbe first.  The 
scenario you outlined here is exactly how ixgbe hardware works:

- Set HLREG0 to enable jumbo frames.  This allows larger frames to be 
accepted, but doesn't limit them to any minimum size.

- Set MHADD (for 82598) or MAXFRS (for 82599 - same register, new name) to 
indicate what the absolute maximum frame size you will receive.  Again, 
doesn't limit the minimum size.

- The networking software can send any size up to MAXFRS (maximum frame 
size) and the hardware will happily receive it and pass it up the stack.

Cheers,
-PJ Waskiewicz
