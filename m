From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 1/8] e1000e: Minimum packet size must be 17 bytes
Date: Tue, 23 Oct 2012 09:37:08 -0700
Message-ID: <5086C7B4.6060202@intel.com>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com> <1350987887-16161-2-git-send-email-jeffrey.t.kirsher@intel.com> <AE90C24D6B3A694183C094C60CF0A2F6026B705D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Tushar Dave <tushar.n.dave@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21482 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757305Ab2JWRHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 13:07:18 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B705D@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 08:25 AM, David Laight wrote:
>> This is a HW requirement. Although a buffer as short as 1 byte is allowed,
>> the total length of packet before, padding and CRC insertion, must be at
>> least 17 bytes.  So pad all small packets manually up to 17 bytes before
>> delivering them to HW.
> Where do such very short packets come from?
> The shortest one I know of have:
>  6 bytes dest-mac
>  6 bytes src-mac
>  2 bytes length
>  3 bytes llc header (eg reflect request).
> 17 bytes total.
>
> 	David
>

This mostly has to do with security fuzz testers sending raw packets at
the interface trying to see what can cause it to hang.  As far as I know
nothing from the stack will be that small, but we still have to support
raw packets that size.

Thanks,

Alex
