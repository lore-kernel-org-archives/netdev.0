From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Patch submission for S2io Xframe driver to 2.6 kernel
Date: Thu, 16 Sep 2004 20:07:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916200735.57909f02.rddunlap@osdl.org>
References: <005001c49c50$c06b9810$a010100a@S2IOtech.com>
	<414A3562.2090803@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ravinandan.arakali@s2io.com, netdev@oss.sgi.com, leonid.grossman@s2io.com,
        raghavendra.koushik@s2io.com, rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <414A3562.2090803@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 20:52:50 -0400 Jeff Garzik wrote:

| Ravinandan Arakali wrote:
| > Jeff,
| > We tried it out with 2.6.7. Can you pls specify the kernel version
| > on which you tried and we will send a patch which works for that version.
| > We will also send a more detailed description of the changes along with
| > that.

For splitting it up :), e.g.:

- 1 patch could be for renaming only, no code/logic changes
  (like TxCfg to tx_cfg); maybe including comments/whitespace changes;

- 1 could be to eliminate (most/all) typedefs

- 1 could be for errata/workarounds

- 1 could be for ethtool support (changes)

- 1 for NAPI support (changes)

- 1 for 2BUFF mode

etc...


Q1:  why is this change needed?

 static inline u64 readq(void *addr)
 {
 	u64 ret = 0;
 	ret = readl(addr + 4);
-	ret <<= 32;
-	ret |= readl(addr);
+	(u64) ret <<= 32;
+	(u64) ret |= readl(addr);




| 
| Always diff against the latest version of the kernel.  You can find out 
| the latest version by going to http://www.kernel.org/  You'll typically 
| want the latest snapshot (preferably), or the latest pre-patch.
| 
| Standard patch submission format is described at 
| http://linux.yyz.us/patch-format.html and in 
| Documentation/SubmittingPatches.
| 
| When submitting a series of patches, it is normal patches to depend on 
| preceding patches.


--
~Randy
