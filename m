From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: FW: Submission for S2io 10GbE driver
Date: Thu, 5 Feb 2004 14:09:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000001c3ec34$af53b8e0$5d50ff11@S2IOtech.com>
References: <40220D15.60603@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Anton Blanchard'" <anton@samba.org>, "'Andi Kleen'" <ak@suse.de>,
        <netdev@oss.sgi.com>, <raghava.vatsavayi@s2io.com>, <iod00d@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <40220D15.60603@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> {read,write}[bwlq] should work the same regardless of whether its big 
> endian or little endian.  The rule is "PCI is defined to be little 
> endian".  On little endian platforms, no byte swapping 
> occurs.  On big endian platforms, the platform will byteswap.  Thus,
the 
> driver should  not have big-endian-specific or PPC64-specific code...
> (you still have to do your own byteswapping for DMA)
> 	Jeff

Hi Jeff, 

It looks like for the swapper issue we can get rid of PPC64-specific
code, but not necessarily of big-endian-specific code.
The behavior you describe is generic for Linux but not for the platform
- on the same box, another OS will not byteswap, for example on the same
pSeries box AIX will not byteswap while Linux will.

So, our ASIC is designed in a way that for a big endian machine the
swapper control need not be touched, and for little endian box both
register and DMA accesses have to be configured to swap - it would be
nice to have the same configuration working on all systems, but this did
not seem possible.

So, for Linux we configure the ASIC to byteswap register access for both
big and little endian boxes.
For DMA (as you pointed out) we need to configure the ASIC to do our own
byteswap, so this init code (or rather just a config parameter) will be
different on big and little endian machine.
Another small difference will be that the ASIC has actually slightly
different statistic counters for  big and little endian.
We can move these (very few) big/little definition into a header file so
the source itself is clean, but I don't see a way to completely get rid
of these... 

Also, looks like we can get rid of all PPC64-specific stuff.
Thanks to everybody who pointed toward a solution (and/or promised to
fix PPC :-)).

Leonid
