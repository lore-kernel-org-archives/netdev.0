From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH net] vmxnet3: Don't enable vlan filters in promiscuous
 mode.
Date: Tue, 9 Aug 2011 20:00:54 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1108091958430.27839@sbhatewara-dev1.eng.vmware.com>
References: <1312794947-3163-1-git-send-email-jesse@nicira.com> <alpine.LRH.2.00.1108091426010.27839@sbhatewara-dev1.eng.vmware.com> <CAEP_g=-dwrhuJddX9Jq1yLuUrH0XKwuEdknOHipdZx8dB64xdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Scott Goldman <scottjg@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:15787 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751568Ab1HJDAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 23:00:51 -0400
In-Reply-To: <CAEP_g=-dwrhuJddX9Jq1yLuUrH0XKwuEdknOHipdZx8dB64xdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Adds and removes are not ignored when in promiscuous mode because the
> active_vlans bitfield is still being updated (this is in the context
> that you clipped out).  When we come out of promiscuous mode,
> vmxnet3_restore_vlan() is called which will update the hardware with
> the vlans that have been registered.  This is much safer than directly
> updating vfTable because it will get overwritten if vmxnet3_set_mc()
> is called again and is potentially very error prone to have it not
> reflect what we actually want programmed in the hardware.
> 

Thats right.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
