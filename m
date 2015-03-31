From: Robert Dolca <robert.dolca@gmail.com>
Subject: Re: [linux-nfc] [PATCH 4/8] NFC: NCI: Add a special nci_request for driver
Date: Tue, 31 Mar 2015 17:07:22 +0300
Message-ID: <CAFPB+Yd3gNEdyeE3+RseTQUy0cEbBiMCajwEN6cRd1Npqmj7Ww@mail.gmail.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-5-git-send-email-robert.dolca@intel.com> <20150326002946.GC10954@ribalta.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Robert Dolca <robert.dolca@intel.com>, linux-nfc@lists.01.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150326002946.GC10954@ribalta.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 26, 2015 at 2:29 AM, Samuel Ortiz <sameo@linux.intel.com> wrote:
> Hi Robert,
>
> On Tue, Feb 24, 2015 at 12:01:48PM +0200, Robert Dolca wrote:
>> This patch adds nci_request_driver and nci_req_complete_driver
>> as a wrapper for __nci_request. When nci_req_complete_driver is
>> called it also sets cmd_cnt to 1. This is done because the response is not
>> sent to the NFC subsystem so cmd_cnt is not decremented there.
>>
>> nci_send_cmd was previously exported in order to send commands to
>> the device from the driver. It shouldn't be used without
>> nci_req_complete_driver because cmd_cnt will have the wrong value.
> Any NCI packet should make it to the NCI core first, because the logic
> and synchornization between Tx and Rx, commands and response is implemented
> there. When exporting this kind of symbols, you're opening a can of worms by
> potentially allowing each driver to implement the same kind of logic
> that's already implemented in the NCI core.
>
> The solution I'd like to see implemented is the following one: Add 1
> additional nci_ops entry for handling proprietary packets on the Rx
> path. From your driver perspective, you call nci_recv_frame for each and
> every packet that you receive: No intercept, no trap. The core will call
> your proprietary packets handler for each packet (NTF or RSP) with a
> proprietary GID.
> You should then be able to remove all the rx work, rx queue and
> intercept logic from your driver.

Thanks for the suggestion. Will do.

Robert
