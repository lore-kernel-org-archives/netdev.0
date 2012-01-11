From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: iwlwifi worse than ever in current git.
Date: Wed, 11 Jan 2012 12:38:43 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB306429E@HASMSX103.ger.corp.intel.com>
References: <20120110184917.GA26973@redhat.com>
 <1326221614.5067.6.camel@dcbw.foobar.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3063085@HASMSX103.ger.corp.intel.com>
 <20120111014243.GA22066@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120111014243.GA22066-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> [  173.145695] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proceed: ssn =
> next_recl = 869
> [  173.147133] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 101
> [  173.147545] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate
> BA Queue 11 on FIFO 1
> [  173.148050] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra =
> b8:c7:5d:0c:39:88 tid = 0

I am missing logs here... You seem to reauthenticate but I can't see disconnection... weird


> [  192.805102] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
> [  192.807392] wlan0: authenticated
> [  192.814840] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can't proceed: ssn
> 1633, next_recl = 139

Stop AGG before we are associated ?!
Is that leftovers from the previous association that was torn down ?

> [  192.818669] wlan0: moving STA b8:c7:5d:0c:39:88 to state 2
> [  192.818939] wlan0: moving STA b8:c7:5d:0c:39:88 to state 1
> [  192.819206] wlan0: moving STA b8:c7:5d:0c:39:88 to state 0
> [  192.824157] wlan0: associate with b8:c7:5d:0c:39:87 (try 1)

Associating to another AP ? A band maybe ?

> [  192.828014] wlan0: RX ReassocResp from b8:c7:5d:0c:39:87 (capab=0x431
> status=0 aid=3)
> [  192.828372] wlan0: associated
> [  192.828515] wlan0: moving STA b8:c7:5d:0c:39:87 to state 1
> [  192.828713] wlan0: moving STA b8:c7:5d:0c:39:87 to state 2
> [  193.853664] wlan0: moving STA b8:c7:5d:0c:39:87 to state 3
> [  278.421399] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proceed: ssn =
> next_recl = 165
> [  278.423946] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 12  WrPtr: 165
> [  278.424007] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate
> BA Queue 12 on FIFO 1
> [  278.424835] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra =
> b8:c7:5d:0c:39:87 tid = 0
> [  285.176431] iwlwifi 0000:04:00.0: I iwl_stop_queue Stop hwq 12 ac 2 stop
> count 1. Queue is full
> [  290.304163] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can't proceed: ssn
> 397, next_recl = 174
> 
> 
> At this point I unloaded, and reloaded the module.
> I had to do this several times until it finally came back up.
> 
> Shortly afterwards..
> 
> [  599.752969] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
> [  599.755359] wlan0: authenticated
> [  599.762131] iwlwifi 0000:04:00.0: I iwl_stop_queue Stop hwq 0 ac 0 stop
> count 1. Tx on passive channel

Interesting. The FW is complaining that you are Txing on a channel that is defined as passive channel...


> [  599.774132] iwlwifi 0000:04:00.0: U iwl_trans_pcie_wake_any_queue Queue
> Status: Q[0] stopped
> [  599.774551] iwlwifi 0000:04:00.0: U iwl_wake_queue Wake hwq 0 ac 0.
> Disassoc: flush queue
> [  599.774921] iwlwifi 0000:04:00.0: U iwl_trans_pcie_wake_any_queue Queue
> Status: Q[1] awake
> [  599.775779] iwlwifi 0000:04:00.0: U iwl_trans_pcie_wake_any_queue Queue
> Status: Q[2] awake
> [  599.776515] iwlwifi 0000:04:00.0: U iwl_trans_pcie_wake_any_queue Queue
> Status: Q[3] awake
> [  599.777198] iwlwifi 0000:04:00.0: I iwl_stop_queue Stop hwq 0 ac 0 stop
> count 1. Tx on passive channel

Again.


There are a few AMPDUs issues here but I guess the worst issue you are seeing is due to the passive channel thing.
Does it feel better with 11n disabled ?



---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
