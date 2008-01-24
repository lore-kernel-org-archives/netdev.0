From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [Bugme-new] [Bug 9808] New: system hung with htb
	QoS
Date: Thu, 24 Jan 2008 12:06:58 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F520444FDF4@orsmsx418.amr.corp.intel.com>
References: <bug-9808-10286@http.bugzilla.kernel.org/>
	<20080124061157.3512a308.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, bilias@edu.physics.uoc.gr,
	"Kok,  Auke-jan H" <auke-jan.h.kok@intel.com>,
	bugme-daemon@bugzilla.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20080124061157.3512a308.akpm@linux-foundation.org>
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

Andrew Morton wrote:
>> I'm also receiving this quite often:
>> Jan 15 12:23:17 ftp kernel: e1000: eth0: e1000_clean_tx_irq:
>> Detected Tx Unit Hang Jan 15 12:23:17 ftp kernel:   Tx Queue        
>> <0> 
>> Jan 15 12:23:17 ftp kernel:   TDH                  <2a>
>> Jan 15 12:23:17 ftp kernel:   TDT                  <17>
>> Jan 15 12:23:17 ftp kernel:   next_to_use          <17>
>> Jan 15 12:23:17 ftp kernel:   next_to_clean        <2a>
>> Jan 15 12:23:17 ftp kernel: buffer_info[next_to_clean]
>> Jan 15 12:23:17 ftp kernel:   time_stamp           <5798144>
>> Jan 15 12:23:17 ftp kernel:   next_to_watch        <2d>
>> Jan 15 12:23:17 ftp kernel:   jiffies              <57988ef>
>> Jan 15 12:23:17 ftp kernel:   next_to_watch.status <0>
>> Jan 15 12:23:19 ftp kernel: e1000: eth0: e1000_clean_tx_irq:
>> Detected Tx Unit Hang 

Looks like a real hardware hang.

Would you be willing to try the 7.6.15 driver at e1000.sourceforge.net,
it has many more fixes for e1000 than what is available in the in-kernel
driver.  I just posted a patch in the "Tracker/Patches" area that
patches 7.6.15 to support the e1000_dump code to dump rings when the tx
hang occurs which will help us figure out a) what software did to the
ring, b) if something is messed up in the ring which we know will hang
the hardware


>> Today for the first time (after applying options to e1000 driver in
>> modprobe.conf) I got a kernel panic:
>> 
>> BUG: unable to handle kernel paging request at virtual address
>> a0379120 
>> EIP: 0060: [<c05db2dc>] Not Tainted VLI
>> EIP is at ip_rcv+0x286/0x4ba
>> Kernel panic - not syncing: Fatal exception in interrupt
>> 
>> This is what I wrote on paper cause there wasn't logged anywhere.
>> Usually it hungs without a kernel panic.

Everyone involved will need more information about the panic to make
progress on the panic.

>> 
>> System in Fedoca Core 8 up2date
>> 2.6.23.9-85.fc8PAE
>> 2x Intel(R) Xeon(TM) CPU 3.20GHz
>> 4G RAM
>> 
>> Without the QoS loaded system never hungs. It must be related to
>> this. However the e1000 error I'm receiving must have to do with the
>> e1000 driver. I've seen this bug in the past that's why I tried to
>> apply the options in modprobe.conf 

>> modprobe.conf options for e1000:
>> options e1000 XsumRX=0 Speed=1000 Duplex=2 InterruptThrottleRate=0
>> FlowControl=3 RxDescriptors=4096 TxDescriptors=4096 RxIntDelay=0
>> TxIntDelay=0 

Please don't use any of these options unless you must, they seem to have
come from some debian forum that someone just posted a SWAG at changing
parameters that fixed him for some unknown reason.

Get back to us with the debug output, the e1000 issue can be covered on
e1000-devel@lists.sourceforge.net

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
