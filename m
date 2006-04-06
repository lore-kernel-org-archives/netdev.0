From: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 06 Apr 2006 15:49:42 +0400
Message-ID: <44350056.80501@kernelpanic.ru>
References: <20060330101218.GA2905@gondor.apana.org.au> <442BDD25.1060000@kernelpanic.ru> <20060331.011245.26474207.davem@davemloft.net> <442D0186.8090705@kernelpanic.ru> <20060331103956.GA12181@gondor.apana.org.au> <442D1B67.8000804@kernelpanic.ru> <20060331121007.GA2146@king.bitgnome.net> <442D1F26.8050601@kernelpanic.ru> <20060331123514.GA13500@gondor.apana.org.au> <20060403210123.GA27698@king.bitgnome.net> <20060403213907.GA32406@linuxace.com> <44319AFF.4090101@kernelpanic.ru> <Pine.WNT.4.63.0604051500530.2496@jbrandeb-desk.amr.corp.intel.com> <Pine.LNX.4.64.0604051734230.9255@lindenhurst-2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Oester <kernel@linuxace.com>,
	Mark Nipper <nipsy@bitgnome.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, jrlundgren@gmail.com,
	cat@zip.com.au, djani22@dynamicweb.hu, yoseph.basri@gmail.com,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, Andi Kleen <ak@suse.de>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.LNX.4.64.0604051734230.9255@lindenhurst-2.jf.intel.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

Hello, Jesse Brandeburg.

On 06.04.2006 04:42 you said the following:

> I built and tested the driver with patches on 2.6.16, with pci-x adapters.  
> I removed some workarounds for PCIe adapters, but I dont think anyone 
> having this problem has a PCIe adapter anyway.  I saw no TX hangs and ran 
> some bi-directional tests, so i think the driver should work okay.  Just 
> warning you I did minimal testing.
> 
> *********************
> e1000: transmit the old fashioned way
> 
> It seems back in the day of 2.6.11, there were no sk_forward_alloc
> asserions.  Forward port that transmit code to see if it fixes the issues
> in today's kernel.  Unfortunately it doesn't have all the bug fixes that
> the current code has, but if we get transmit timeouts we can add in
> workarounds appropriately.
> 
> this changes only the e1000_tso function

With this one still having:

TCP: Treason uncloaked! Peer 80.72.16.78:11460/80 shrinks window 
2223569515:2223569516. Repaired.
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (283)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (150)



> e1000: implement old xmit_frame
> 
> It seems back in the day of 2.6.11, there were no sk_forward_alloc
> asserions.  Forward port that transmit code to see if it fixes the issues
> in today's kernel.  Unfortunately it doesn't have all the bug fixes that
> the current code has, but if we get transmit timeouts we can add in
> workarounds appropriately.
> 
> this changes the e1000_xmit_frame function, and some ancilliaries
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>



Can't apply this one:

[zhmurov@builds linux-2.6.16]$ patch -p1 < 
../../../SOURCES/linux-2.6.16-e1000-implement_old_xmit_frame.patch
patching file drivers/net/e1000/e1000_main.c
Hunk #1 succeeded at 2620 (offset -105 lines).
Hunk #2 FAILED at 2695.
Hunk #4 FAILED at 2837.
Hunk #5 FAILED at 2868.
Hunk #6 FAILED at 2899.
4 out of 6 hunks FAILED -- saving rejects to file 
drivers/net/e1000/e1000_main.c.rej



-- 
Boris B. Zhmurov
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
