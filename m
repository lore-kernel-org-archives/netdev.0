From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Tue, 15 Jan 2008 13:53:43 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52042FA541@orsmsx418.amr.corp.intel.com>
References: <200801150625.10823.elendil@planet.nl><20080114.215317.38045859.davem@davemloft.net><200801151504.10047.elendil@planet.nl> <20080115190458.rxt3yhb2o8o404kc@mail.bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <slavon@bigtelecom.ru>, "Frans Pop" <elendil@planet.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757421AbYAOVyO@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20080115190458.rxt3yhb2o8o404kc@mail.bigtelecom.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

slavon@bigtelecom.ru wrote:
> Quoting Frans Pop <elendil@planet.nl>:
>>> (Note this isn't the final correct patch we should apply.  There  is
>>> no reason why this revert back to the older ->poll() logic  here
>>> should have any effect on the TX hang triggering...)
>> 
>> s/no reason/no obvious reason/ ? ;-)

The tx code has an "early exit" that tries to limit the amount of tx
packets handled in a single poll loop and requires napi or interrupt
rescheduling based on the return value from e1000_clean_tx_irq.

see this code in e1000_clean_tx_irq

4005 #ifdef CONFIG_E1000_NAPI
4006 #define E1000_TX_WEIGHT 64
4007 >       >       /* weight of a sort for tx, to avoid endless
transmit cleanup */
4008 >       >       if (count++ == E1000_TX_WEIGHT) break;
4009 #endif

I think that is probably related.  For a test you could apply the
original patch, and remove this "break" just by commenting out line
4008.  This would guarantee all tx work is cleaned at every e1000_clean

Jesse
