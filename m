From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 23:45:32 +0200
Message-ID: <1237412732.29116.2.camel@lb-tlvb-eliezer>
References: <49C12E64.1000301@us.ibm.com>
 <87prge1rhu.fsf@basil.nowhere.org> <49C16294.8050101@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andi Kleen" <andi@firstfloor.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>
To: "Vernon Mauery" <vernux@us.ibm.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <49C16294.8050101@us.ibm.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-03-18 at 14:07 -0700, Vernon Mauery wrote:
> > 
> > The real "fix" would be probably to use a multi queue capable NIC
> > and a NIC driver that sets up multiple queues for TX (normally they
> > only do for RX). Then cores or a set of cores (often the number
> > of cores is larger than the number of NIC queues) could avoid this
> > problem. Disadvantage: more memory use.
> 
> Hmmm.  So do either the netxen_nic or bnx2x drivers support multiple
> queues?  (that is the HW that I have access to right now).  And do I
> need to do anything to set them up?
> 
The version of bnx2x in net-next support multi Tx queues (and Rx). It
will open an equal number of Tx and Rx queues up to 16 or the number of
cores in the system. You can validate that all queues are transmitting
with "ethtool -S" which has per queue statistics in that version.

I hope it will help,
Eilon


