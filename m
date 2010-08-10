From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: Re: e1000e crashes with 2.6.34.x and ThinkPad T60
Date: Tue, 10 Aug 2010 09:34:52 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A900164D9279F@orsmsx509.amr.corp.intel.com>
References: <20100724092644.GA13353@torres.zugschlus.de>
	<EA929A9653AAE14F841771FB1DE5A1366000F42E28@rrsmsx501.amr.corp.intel.com>
	<20100730125452.GA21444@torres.zugschlus.de>
	<EA929A9653AAE14F841771FB1DE5A13660024083FE@rrsmsx501.amr.corp.intel.com>
	<20100810120458.GB21511@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Network Developers <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>, Linux
To: Marc Haber <mh+linux-kernel@zugschlus.de>, "Tantilov, Emil S"
	<emil.s.tantilov@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100810120458.GB21511@torres.zugschlus.de>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tuesday, August 10, 2010 5:05 AM, Marc Haber wrote:
> On Wed, Aug 04, 2010 at 12:23:45PM -0600, Tantilov, Emil S wrote:
>> Looking at your lspci output - your system has a slightly different
>> HW, but I don't know if this is significant. 
>> 
>> Are you loading the kernel with any parameters (cat /proc/cmdline)?
> 
> BOOT_IMAGE=/vmlinuz-2.6.35-zgws1 root=/dev/mapper/root ro
> resume=/dev/mapper/swap0 quiet splash radeon.modeset=1
> 
>> Do you have firewall configured (iptables -L)?
> 
> I am working pretty intensively with virtual machines which are natted
> here and there. I have a handful of MASQUERADE rules in the
> nat/POSTROUTING chain, but that's it.
> 
>> Also now that 2.6.35 is out - could you give it a try and see if the
>> situation had improved? 
> 
> Tried, no improvement.
> 
> Greetings
> Marc

[adding e1000-devel, the Intel wired ethernet developers mailing list]

We have had other recent reports of issues with this part that are due to
ASPM L1 being enabled.  Would you please try disabling L1 after the driver
is loaded as follows (assuming your adapter is still PCI bus/device/number
02:00.0 as indicated in the lspci output you provided earlier):
1) First check the hexadecimal value of the LnkCtl register -
# setpci -s 2:0.0 0xf0
2) Disable ASPM (both L0s and L1) by zeroing out bits 0 and 1 in the value
returned by the previous step.  For example, if it returned 42 (hex 42,
that is) -
# setpci -s 2:0.0 0xf0=0x40
3) Confirm ASPM is disabled by checking the output from lspci again.

Please let us know if this helps your situation, thanks.
Bruce.

------------------------------------------------------------------------------
This SF.net email is sponsored by 

Make an app they can't live without
Enter the BlackBerry Developer Challenge
http://p.sf.net/sfu/RIM-dev2dev 
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
