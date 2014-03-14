From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next 02/16] ixgbe: fix spinlock recursion with netpoll and
 busy poll
Date: Fri, 14 Mar 2014 20:40:25 +0000
Message-ID: <87618083B2453E4A8714035B62D679924FF2B0DD@FMSMSX105.amr.corp.intel.com>
References: <1394790446-31591-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1394790446-31591-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <20140314.145850.706702494963811330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"asharma@fb.com" <asharma@fb.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140314.145850.706702494963811330.davem@davemloft.net>
Content-Language: en-US
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, March 14, 2014 11:59 AM
>To: Kirsher, Jeffrey T
>Cc: Tantilov, Emil S; netdev@vger.kernel.org;
>gospo@redhat.com; sassmann@redhat.com; asharma@fb.com;
>stable@vger.kernel.org; Keller, Jacob E
>Subject: Re: [net-next 02/16] ixgbe: fix spinlock recursion
>with netpoll and busy poll
>
>From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>Date: Fri, 14 Mar 2014 02:47:12 -0700
>
>> From: Emil Tantilov <emil.s.tantilov@intel.com>
>>
>> This patch resolves a hang with busy poll when used with netconsole.
>>
>> The main change is the check for netpoll packets in ixgbe_poll() which
>> prevents a call to spin_lock_bh() while interrupts are disabled.
>>
>> In addition it removes the call to netif_rx() since netif_receive_skb()
>> can deal with netpoll packets and also replaced the global adapter flag
>> with per-q_vector bool that indicates Rx packet from netpoll which
>> should help with performance.
>>
>> CC: Arun Sharma <asharma@fb.com>
>> CC: stable <stable@vger.kernel.org>
>> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
>> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
>Eric Biederman and co. are working to make this completely unnecessary.
>
>What is going to happen is that poll will be called with a budget of
>zero, and no RX processing will thus occur, for netpoll.
>
>Nothing in the RX path can handle being invoked from hardware
>interrupt context, so we have to prevent it completely in all
>drivers that support netpoll.

I noticed Eric's patches and this is obviously the better way to deal with it, but once the netpoll_rx patches are accepted will they make it into previous stable releases? Currently kernels between 3.11 and 3.13 (assuming Eric's changes make it into 3.14) will hang when netpoll and busy poll are used together.

Thanks,
Emil
