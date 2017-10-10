From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 05/14] i40e/i40evf: always set the CLEARPBA flag when
 re-enabling interrupts
Date: Tue, 10 Oct 2017 13:07:31 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD008ECFE@AcuExch.aculab.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
 <20171009223841.2557-6-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jacob Keller <jacob.e.keller@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:56456 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755272AbdJJNHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 09:07:41 -0400
In-Reply-To: <20171009223841.2557-6-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> Sent: 09 October 2017 23:39
> In the past we changed driver behavior to not clear the PBA when
> re-enabling interrupts. This change was motivated by the flawed belief
> that clearing the PBA would cause a lost interrupt if a receive
> interrupt occurred while interrupts were disabled.
> 
> According to empirical testing this isn't the case. Additionally, the
> data sheet specifically says that we should set the CLEARPBA bit when
> re-enabling interrupts in a polling setup.

I presume this if the MSI-X Pending Bit Array?
Normally this bit is cleared when the interrupt is actioned.

If request the device clear the PBA then it (probably) won't
raise an interrupt when it is unmasked (by clearing the 'masked' bit).

If you've just checked all the rings (with the interrupt masked)
and you clear the PBA bit when you unmask interrupts then you will
need to do another scan of the rings to pick up any packets that
arrived (or tried to signal an interrupt) in that small gap.

'Empirical testing' probably won't hit the timing window.

	David
