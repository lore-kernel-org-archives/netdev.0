From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 19:31:55 -0700
Message-ID: <4685C09B.7040908@intel.com>
References: <1183138159.17243.16.camel@blaa>	
	<20070629175006.GB3917@falooley.org>
	<468571C6.3090305@garzik.org>	 <46857C08.4030303@intel.com>	
	<20070629150350.414553d4.akpm@linux-foundation.org>	
	<4685838D.9080108@garzik.org>
	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
	<46859F3F.305@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46859F3F.305@garzik.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Andrew Grover wrote:
>> I think making e1000new ICH9-and-newer isn't really the best place to
>> split it. The Windows e1000 driver got split on the PCI->PCIe
>> transition, something that clearly delineated what nics one driver
>> supported, and the other. There's no real technical reason for
>> splitting now other than "this was when e1000old collapsed under its
>> own weight".
>>
>> The PCIe adapters are also the first ones to support multiple queues
>> IIRC, maybe that would be an another actual technical reason to split
>> it there?
> 
> Can knowledgeable people characterize the PCIe adapters somehow?  Is 
> that "ICH8-era and later", or does it go back further than that?

very brief outline:


all the pci-express adapters that are supported are extremely similar:

- they all support 2 queues
- the register sets are (almost entirely) identical
- there is minimal feature variance between 82571/2/3, esb2lan, ich8/9

The major differences between 82571/2/3, esb2lan and ich8/9 are PHY-based (4 
different PHY's basically, one for 82571/2/3, one for esb2lan and 2 for ich8/9, 
excluding fiber and serdes here) and NVM/EEPROM.


ich8 and 9 are consistent with 82571/2/3 - on-board nic's based on the 82571 
design with different PHY's, and added features for the newer demands. A driver 
split here would be possible but not justified IMHO.


this above discussion excludes the new server NIC hardware that we are about to 
release (aka 82575), which will have it's own driver, since the register set and 
descriptor types are completely different.

if you want a quick view of features by chipset type, open the patch and search 
forward to /e1000_setup_flags/. The list below shows historically which features 
were added from time to time. This one function that sets up all these features 
is a quick reference that easily shows the distinction between pre-pcie and pcie 
e1000 hardware.


Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
