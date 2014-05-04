From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v5 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Sun, 4 May 2014 20:43:51 +0200
Message-ID: <20140504184351.GA4471@electric-eye.fr.zoreil.com>
References: <20140502175242.GB1156@newterm.pl>
 <20140503114029.GA19315@electric-eye.fr.zoreil.com>
 <20140504110413.GE1156@newterm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Darek Marcinkiewicz <reksio@newterm.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140504110413.GE1156@newterm.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Darek Marcinkiewicz <reksio@newterm.pl> :
> On Sat, May 03, 2014 at 01:40:29PM +0200, Francois Romieu wrote:
[...]
> Thank you. I am attaching 2 of thse to this repsonse - the other two 
> are no longer relevant due to the changes I made into the driver.
> One of the attached patches is slightly modfied by simply having one hunk
> removed (that hunk was applying to the code that was removed in next rev 
> of the driver). Not sure how to proceed with those patches, shall I simply
> sent out these patches to this list as a separate messages?

You should submit a complete series if you want them separated - git
format-patch does wonders here - or include these directly in your own
patch as I don't really care for the credit.

[...]
> I have changed the code to use much modest value - it is set to be of the
> size of the fifo now. I think that this value is much better, but of course
> having this configurable would be even better.

(see ethtool_ops.[gs]et_ringparam)

[...]
> No, there is really no interrupt, hence the timer. Also on this device I wouldn't 
> expect any bursts of data. What happens here, during regular operation of the 
> device, is a periodic exchange of (few) ethernet packets between host cpu and
> terminals attached to the EtherCAT bus. As for the locking on the tx path,
> I have removed that completely on receiving path. I simply didn't know 
> that it is such a big no-no here :)

Ok.

Regarding tx_dnext updates, you may add a short notice in ec_bhf_start_xmit
and ec_bhf_process_tx explaining that the periodic poller will somehow end
working with the right value, whence no (smp_)barrier at all.

-- 
Ueimor
