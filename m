From: Grant Grundler <iod00d@hp.com>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: Thu, 5 Feb 2004 14:34:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040205223413.GB2508@cup.hp.com>
References: <40220D15.60603@pobox.com> <000001c3ec34$af53b8e0$5d50ff11@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Jeff Garzik'" <jgarzik@pobox.com>, "'Anton Blanchard'" <anton@samba.org>,
        "'Andi Kleen'" <ak@suse.de>, netdev@oss.sgi.com,
        raghava.vatsavayi@s2io.com, iod00d@hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
Content-Disposition: inline
In-Reply-To: <000001c3ec34$af53b8e0$5d50ff11@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 05, 2004 at 02:09:09PM -0800, Leonid Grossman wrote:
> It looks like for the swapper issue we can get rid of PPC64-specific
> code, but not necessarily of big-endian-specific code.

right

> The behavior you describe is generic for Linux but not for the platform
> - on the same box, another OS will not byteswap, for example on the same
> pSeries box AIX will not byteswap while Linux will.

While I understand the desire to share the same driver across OSs,
providing "glue" code like sym53c8xx_2 drivers does can be very ugly.
You might look at that driver a bit and try to compare 2.4 vs 2.6.

> So, our ASIC is designed in a way that for a big endian machine the
> swapper control need not be touched, and for little endian box both
> register and DMA accesses have to be configured to swap - it would be
> nice to have the same configuration working on all systems, but this did
> not seem possible.

It's probably not. It sounds like the Tigon2 driver (acenic) which has
similar HW support. You see how endianess is handled there.

...
> Another small difference will be that the ASIC has actually slightly
> different statistic counters for  big and little endian.
> We can move these (very few) big/little definition into a header file so
> the source itself is clean, but I don't see a way to completely get rid
> of these... 

that's ok I think.

cheers,
grant
