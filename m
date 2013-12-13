From: Francesco Fusco <ffusco@redhat.com>
Subject: Re: [PATCH net-next v2 2/2] net: ovs: use CRC32 accelerated flow
 hash if available
Date: Fri, 13 Dec 2013 10:55:23 +0100
Message-ID: <52AAD98B.7030100@redhat.com>
References: <1386860946-1621-1-git-send-email-ffusco@redhat.com> <1386860946-1621-3-git-send-email-ffusco@redhat.com> <CAEP_g=-JBT_XVvwSa4xOwVoTysoL0Z8zJc-ERSHJc96+qrA99Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Thomas Graf <tgraf@redhat.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49920 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495Ab3LMJ4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 04:56:36 -0500
In-Reply-To: <CAEP_g=-JBT_XVvwSa4xOwVoTysoL0Z8zJc-ERSHJc96+qrA99Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2013 09:20 PM, Jesse Gross wrote:
> Out of curiosity, did you try using crc32q? OVS data structures are
> already aligned to 8 bytes. It would also be interesting to know if a
> parallelized implementation is worthwhile, although my guess is that
> the OVS flow key is not quite long enough.

We did not try with crc32q yet because we had the very same concerns.
In the general case, when the length of the key is not a multiple of 8 
bytes, we will have to use the crc32q to process multiple 64 bit 
numbers, then process the the rest with a crc32l. My guess is that the
performance benefit won't be that high.

But we will try that out and if the outcome will be positive, we will 
submit a follow up patch.

Best,
Francesco
