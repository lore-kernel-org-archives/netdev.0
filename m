From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission for S2io 10GbE driver
Date: Mon, 16 Feb 2004 17:12:40 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40314058.2000307@pobox.com>
References: <000201c3f4d2$2a5ddd90$7410100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "'Andi Kleen'" <ak@suse.de>,
        "'Stephen Hemminger'" <shemminger@osdl.org>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>,
        "'jamal'" <hadi@cyberus.ca>, "'Grant Grundler'" <iod00d@hp.com>,
        "'Anton Blanchard'" <anton@samba.org>,
        "'Jes Sorensen'" <jes@trained-monkey.org>,
        raghavendra.koushik@s2io.com,
        "'ravinandan arakali'" <ravinandan.arakali@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <000201c3f4d2$2a5ddd90$7410100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Leonid Grossman wrote:
> 1. At the moment, lspci output looks like
> "02:02.0 Ethernet controller: Unknown device 17d5:5831 (rev 02)"; do we
> need to submit a patch for drivers/pci/pci.ids?

http://pciids.sourceforge.net/

The file drivers/pci/pci.ids is only associated with /proc/pci strings, 
and I'm trying to deprecate it :)


> 2. The card fully supports Ethernet and TCP header separation in
> hardware (so called receive 3-buffer mode).
> The mode may have some performance advantages but so far we did not
> implement the mode in Linux since it seems that Linux stack can't handle
> the fragmented buffers in the receive path. Is this a correct
> assumption, does receive buffer has to be continuous?

In theory, the skb can be fragmented.  I'm not as much as an expert in 
the ipv4/tcp/socket levels of the net stack, but I don't recall any 
place that yet supports skb frags on receive?

I think that's likely an area that would need some minor 
adjustments/additions in the upstream kernels, but not major surgery, 
since the skb already supports creating, noticing, and freeing frags.

	Jeff
