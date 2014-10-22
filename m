From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv3 RFC net-next 0/4] sunvnet: NAPIfy sunvnet
Date: Wed, 22 Oct 2014 14:57:57 -0400
Message-ID: <20141022185757.GA8134@oracle.com>
References: <20141015164234.GA11840@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: davem@davemloft.net, bob.picco@oracle.com, dwight.engen@oracle.com,
	raghuram.kothakota@oracle.com
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141015164234.GA11840@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Please hold off on this patch-set for the moment.

I just discovered a subtle bug that can be triggered when multiple
ldc events (e.g., UP and DATA_READY) are passed up from
ldc_rx -> send_events in one shot- we need to treat the vnet_port's
(new field) rx_event as a bit mask, and need to unroll send_events() 
into vnet_event_napi.

the result of this bug is that inter-vnet handshake can sometimes
fail incorrectly causing things to needlessly go thorugh the
switchport. I'm working on the fix for this, I'll send out
PATCHv5 for this series shortly.

Apologies for the confusion.

--Sowmini


