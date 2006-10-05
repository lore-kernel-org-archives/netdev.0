From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Thu, 5 Oct 2006 17:35:52 +0200
Message-ID: <200610051735.52309.IvDoorn@gmail.com>
References: <4523DA7D.2080604@web.de> <200610051700.31171.IvDoorn@gmail.com> <20061005171357.44a8d413@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jan Kiszka <jan.kiszka@web.de>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:32104 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932133AbWJEPgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 11:36:47 -0400
Received: by nf-out-0910.google.com with SMTP id o25so820280nfa
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2006 08:36:45 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061005171357.44a8d413@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 05 October 2006 17:13, Jiri Benc wrote:
> On Thu, 5 Oct 2006 17:00:31 +0200, Ivo van Doorn wrote:
> > Basically it comes down to this:
> > 
> > Sep 13 12:27:34 wz4a kernel: wlan0: Creating new IBSS network, BSSID 7a:b9:60:8a:84:39
> > Sep 13 12:27:34 wz4a kernel: BUG: scheduling while atomic: swapper/0x00000100/0
> > Sep 13 12:27:34 wz4a kernel:  <b02701e7> schedule+0x43/0xa84  <b01ef8b8> extract_buf+0x97/0xc8
> > Sep 13 12:27:34 wz4a kernel:  <b0270ca8> wait_for_completion+0x6a/0x9f  <b0116f2d> default_wake_function+0x0/0xc
> > Sep 13 12:27:34 wz4a kernel:  <c08ac59f> usb_start_wait_urb+0x98/0xdc [usbcore]  <c08ac418> timeout_kill+0x0/0x5 [usbcore]
> > Sep 13 12:27:34 wz4a kernel:  <c08ac7d5> usb_control_msg+0xc3/0xde [usbcore]  <c0b6c0f1> rt2x00_vendor_request+0x7c/0xa6 [rt73usb]
> > Sep 13 12:27:34 wz4a kernel:  <c0b6fa68> rt73usb_reset_tsf+0x30/0x59 [rt73usb]  <c0bdb3e8> ieee80211_sta_join_ibss+0x3a/0x572 [80211]
> > Sep 13 12:27:34 wz4a kernel:  <b011cea9> printk+0x14/0x18  <c0bdaa4a> ieee80211_rx_bss_add+0x88/0x90 [80211]
> > Sep 13 12:27:34 wz4a kernel:  <c0bdbc2e> ieee80211_sta_find_ibss+0x30e/0x366 [80211]  <c0bdda17> ieee80211_sta_timer+0x0/0x18f [80211]
> > Sep 13 12:27:34 wz4a kernel:  <c0bdda91> ieee80211_sta_timer+0x7a/0x18f [80211]  <c0bdda17> ieee80211_sta_timer+0x0/0x18f [80211]
> > Sep 13 12:27:34 wz4a kernel:  <b01241b1> run_timer_softirq+0x10b/0x153  <b0120a52> __do_softirq+0x58/0xc2
> > Sep 13 12:27:34 wz4a kernel:  <b0120aea> do_softirq+0x2e/0x32  <b0104fe6> do_IRQ+0x1e/0x24
> > Sep 13 12:27:34 wz4a kernel:  <b0103592> common_interrupt+0x1a/0x20  <c0827484> acpi_processor_idle+0x18a/0x39e [processor]
> > Sep 13 12:27:34 wz4a kernel:  <b0101e77> cpu_idle+0x8f/0xa8  <b03026d2> start_kernel+0x355/0x35c
> 
> So this will be solved for free when sta_timer is converted to a
> workqueue.

Hi,

True, this is what I realized later as well. :)
I have asked for confirmation by the bug submitter.

Ivo
