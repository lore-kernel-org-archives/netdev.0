From: shawvrana@gmail.com
Subject: Re: e1000 TX unit hang (redux)
Date: Tue, 11 Jul 2006 14:53:27 -0700
Message-ID: <200607111453.27427.shaw@vranix.com>
References: <200607111116.41932.shaw@vranix.com> <44B4139B.7060907@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kernel@linuxace.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:898 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932155AbWGKVxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 17:53:35 -0400
Received: by py-out-1112.google.com with SMTP id t32so2078pyc
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 14:53:34 -0700 (PDT)
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44B4139B.7060907@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Auke,

On Tuesday 11 July 2006 14:09, Auke Kok wrote:
>
>  > that seems to address this problem by creating a
> >
> > tx_timeout_factor relative to the speed of the NIC.  However, there is no
> > mention of this workaround/fix on the bug at the link above and I haven't
> > found any discussion of it here on netdev.
>
> I wouldn't even know what patch you are talking about (?!)

Ok, well, the patch is in 2.6.17.4 and looks to have been announced in the 
2.6.16-c2 changelog -- http://lwn.net/Articles/170529/ -- and written by Jeff 
Kirsher.  I haven't been able to find a link to the original patch submission 
anywhere.  The code looks something like this now: 

        /* Detect a transmit hang in hardware, this serializes the
         * check with the clearing of time_stamp and movement of i */
        adapter->detect_tx_hung = FALSE;
        if (tx_ring->buffer_info[eop].dma &&
            time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
                       (adapter->tx_timeout_factor * HZ))
            && !(E1000_READ_REG(&adapter->hw, STATUS) &
                 E1000_STATUS_TXOFF)) {

..where the tx_timeout_factor has been added and is set in the watchdog code 
based on the link speed. 

> that's not only impossible but also unlikely - we don't push changes to 2.4 
> kernels anymore a lot, I think the last change is likely older than 2.4.28.

I'm sure you're right.  Jumped to conclusions on a patch I saw posted at 
redhat.. I'll be more careful next time :)

I'll also try to get some better debugging info from my side.

Thanks.
Shaw
