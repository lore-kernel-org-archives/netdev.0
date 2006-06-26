From: Andrew Morton <akpm@osdl.org>
Subject: Re: FW: + qla3xxx-is-bust.patch added to -mm tree
Date: Mon, 26 Jun 2006 12:24:23 -0700
Message-ID: <20060626122423.88206b8e.akpm@osdl.org>
References: <0BB3E5E7462EEA4295BC02D49691DC07176AB0@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, bunk@stusta.de, netdev@vger.kernel.org,
	linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39813 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932939AbWFZT1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 15:27:53 -0400
To: "Ron Mercer" <ron.mercer@qlogic.com>
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC07176AB0@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Jun 2006 12:02:21 -0700
"Ron Mercer" <ron.mercer@qlogic.com> wrote:

> The attached patch fixes the compile bugs you indicated plus some of
> Jeff Garzik's concerns.
> 
> - Removed non-NAPI code.
> - Removed un-needed PCI_POSTING macro.
> - Converted msleep() to ssleep() where waiting > 1 sec.
> - Broke up ql_link_state_machine into two functions for indent purposes.
> - Cleaned up ql3xxx_remove().
> - Cleaned up banner print and moved to probe.
> - Got rid of tx_lock. Not needed.
> - Fix send routine for big endian mapping problem.
> - Version change to k35.
> 
> Built and tested on the latest git tree on x86 and PPC64 platforms.

Thanks.

Is the device hotpluggable?   If so, this:

	qdev->index = cards_found;

in the probe() handler might do odd things - it'll just keep increasing as
the card is removed and re-added.

iirc, that's a common problem with net drivers.  AFAICT it'll cause only
cosmetic oddities here.

