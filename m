From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: RE: [E1000-devel] 82571EB: Detected Hardware Unit Hang
Date: Tue, 27 Nov 2012 17:32:28 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD62F2D8070@ORSMSX102.amr.corp.intel.com>
References: <509B5038.8090304@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com>
	<50A30656.6090508@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA8913348B105@ORSMSX102.amr.corp.intel.com>
	<50A43828.6000702@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA8913349A0B4@ORSMSX102.amr.corp.intel.com>
	<50A9C5CC.1030300@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA8913349EB41@ORSMSX102.amr.corp.intel.com>
	<50AB8471.7080607@oracle.com>
	<9B4A1B1917080E46B64F07F2989DADD62F2D62D6@ORSMSX102.amr.corp.intel.com>
	<50B41077.3080009@oracle.com> <b46b84cf-3688-4fd7-b741-4e96f2663517@default>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mary Mcgrath <mary.mcgrath@oracle.com>,
	Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b46b84cf-3688-4fd7-b741-4e96f2663517@default>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Forgive me if I'm being too repetitious as I think some of this has been mentioned in the past.

We (and by we I mean the Ethernet part and driver) can only change the advertised availability of a larger MaxPayloadSize. The size is negotiated by both sides of the link when the link is established. The driver should not change the size of the link as it would be poking at registers outside of its scope and is controlled by the upstream bridge (not us).

You also need to check all the PCIe links to get to the device. There can be several to get from the root complex, through bridges, to the endpoint Ethernet controller. The Ethernet part and driver has no control over any other links. You'll have to talk to the motherboard manufacturer about those links.

Your original problem appears to be hangs and Tushar asked you to the entire path of PCIe connections from the root complex to the endpoint. Any mismatches in payload can cause hangs and I believe you have had the problem in the past. I'm sure you remember all the lspci commands to list the tree view and to dump all the details from each of the links and I would suggest you do that to check to see that the payload sizes match. What I do is "lspci -tvvv" to see what's connected, then "lspci -s xx:xx.x -vvv" to check the devices on the link.

Thanks.

Todd Fujinaka
Technical Marketing Engineer
LAN Access Division (LAD)
Intel Corporation
todd.fujinaka@intel.com
(503) 712-4565


-----Original Message-----
From: Mary Mcgrath [mailto:mary.mcgrath@oracle.com] 
Sent: Monday, November 26, 2012 6:07 PM
To: Joe Jin
Cc: netdev@vger.kernel.org; e1000-devel@lists.sf.net; linux-kernel@vger.kernel.org
Subject: Re: [E1000-devel] 82571EB: Detected Hardware Unit Hang

Joe
Thank you for working this.
I would love to find out how they expect a customer to make the modification To  "word  0x1A, and see if the 8th bit is 0 or 1, and to change to 0."

I have in turn asked the ct for the lspci command on eth3, maybe the incorrect setting is upstream.

Again,  thank you.
Regards
Mary



-----Original Message-----
From: Joe Jin
Sent: Monday, November 26, 2012 8:00 PM
To: Fujinaka, Todd
Cc: Dave, Tushar N; netdev@vger.kernel.org; e1000-devel@lists.sf.net; linux-kernel@vger.kernel.org; Mary Mcgrath
Subject: Re: [E1000-devel] 82571EB: Detected Hardware Unit Hang

On 11/27/12 00:23, Fujinaka, Todd wrote:
> If you look at the previous section, DevCap, you'll see that it's 
> correctly advertising 256 bytes but the system is negotiating 128 for 
> the link to the Ethernet controller. Things on the "other" side of the 
> link are controlled outside of the e1000 driver.
> 
> Tushar's first suggestion was to check the PCIe payload settings in 
> the entire chain. Have you done that? Mismatches will cause hangs.

Hi Todd,

So far I had to know how to modify the maxpayload size, since BIOS have not entry to change this, so I had to use ethtool, now I need to get the offset of MaxPayload size in eeprom, I ever tried to find from Intel online document but failed, any idea?

Thanks in advance,
Joe

------------------------------------------------------------------------------
Monitor your physical, virtual and cloud infrastructure from a single web console. Get in-depth insight into apps, servers, databases, vmware, SAP, cloud infrastructure, etc. Download 30-day Free Trial.
Pricing starts from $795 for 25 servers or applications!
http://p.sf.net/sfu/zoho_dev2dev_nov
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
