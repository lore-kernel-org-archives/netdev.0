From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: ixgbe dump
Date: Mon, 22 Nov 2010 19:31:12 -0800
Message-ID: <29F4ED941D916B48B88B4D2A4F3D1B9C01CC08FBCF@orsmsx509.amr.corp.intel.com>
References: <4CE47FA6.8050600@kernel.org>
	<29F4ED941D916B48B88B4D2A4F3D1B9C01CBFC68C5@orsmsx509.amr.corp.intel.com>
	<AANLkTinQ-6CaUY3bYd+SMBCaNvU5YiXL2P+gh7N1tM-x@mail.gmail.com>
	<1290468133.2603.2.camel@jtkirshe-MOBL1>
 <AANLkTi=Esp=y2ci=RrCeXYVaxnbrJY3NXpaBgPOBqc7p@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12115 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756Ab0KWDbO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 22:31:14 -0500
In-Reply-To: <AANLkTi=Esp=y2ci=RrCeXYVaxnbrJY3NXpaBgPOBqc7p@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Yinghai,

I was hoping we could have had this patch pushed upstream sooner, but we have quite a few in our internal queue right now.

If this doesn't solve your issue please let me know.

Thanks,
-Don Skidmore <donald.c.skidmore@intel.com>




After freeing the rings we were not zeroing out the ring count values.
This patch now clears these counts correctly.

Reported-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fbad4d8..eee0b29 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4771,6 +4771,9 @@ void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i] = NULL;
 	}
 
+	adapter->num_tx_queues = 0;
+	adapter->num_rx_queues = 0;
+
 	ixgbe_free_q_vectors(adapter);
 	ixgbe_reset_interrupt_capability(adapter);
 }


>-----Original Message-----
>From: yhlu.kernel@gmail.com [mailto:yhlu.kernel@gmail.com] On Behalf Of
>Yinghai Lu
>Sent: Monday, November 22, 2010 3:28 PM
>To: Kirsher, Jeffrey T
>Cc: Skidmore, Donald C; Brandeburg, Jesse; David Miller; NetDev
>Subject: Re: ixgbe dump
>
>On Mon, Nov 22, 2010 at 3:22 PM, Jeff Kirsher
><jeffrey.t.kirsher@intel.com> wrote:
>>
>> It is not posted yet. Don got the patch to our testers and they are
>> doing a quick validation on the patch before I post it to netdev.
>>
>> I can send you the patch, so that you can assist in letting us know if
>> it resolves the issue.
>
>sure. please send that to me.
>
>Thanks
