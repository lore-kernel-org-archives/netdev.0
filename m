From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [PATCH net-drivers-2.6 2/10] e1000: use netif_poll_{enable|disable}
Date: Tue, 15 Feb 2005 14:48:24 -0800
Message-ID: <468F3FDA28AA87429AD807992E22D07E04438B87@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
        "Francois Romieu" <romieu@fr.zoreil.com>
Content-class: urn:content-classes:message
To: "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I agree that this causes our ISR to be called where no useful work will
be done -- netif_rx_schedule_prep() will fail till netif_poll_enable is
called.
However, there should not be any adverse side effects due to this.

Will fix this in the next release.

Ganesh.

>-----Original Message-----
>From: Chilakala, Mallikarjuna
>Sent: Tuesday, February 15, 2005 2:32 PM
>To: Venkatesan, Ganesh
>Subject: FW: [PATCH net-drivers-2.6 2/10] e1000: use
>netif_poll_{enable|disable}
>
>
>
>-----Original Message-----
>From: Francois Romieu [mailto:romieu@fr.zoreil.com]
>Sent: Tuesday, February 15, 2005 2:06 PM
>To: Chilakala, Mallikarjuna
>Cc: jgarzik@pobox.com; netdev
>Subject: Re: [PATCH net-drivers-2.6 2/10] e1000: use
>netif_poll_{enable|disable}
>
>Malli Chilakala <mallikarjuna.chilakala@intel.com> :
>[...]
>> diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-
>2.6/drivers/net/e1000.new/e1000_main.c
>> --- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-02-01
>23:10:24.989105880 -0800
>> +++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
2005-02-01
>23:10:26.709844288 -0800
>> @@ -308,6 +308,9 @@ e1000_up(struct e1000_adapter *adapter)
>>  	mod_timer(&adapter->watchdog_timer, jiffies);
>>  	e1000_irq_enable(adapter);
>>
>> +#ifdef CONFIG_E1000_NAPI
>> +	netif_poll_enable(netdev);
>> +#endif
>>  	return 0;
>>  }
>>
>
>It leaves a small(*) window where the irq handler will do nothing with
>the events it receives. If netif_poll_enable() is issued before
>e1000_irq_enable(), the problem disappears.
>
>[*] Assuming CONFIG_PREEMPT=n
>
>--
>Ueimor
