From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Fri, 20 Nov 2009 16:04:47 -0800
Message-ID: <65634d660911201604y6a6a602ex57ffaf788a3a2be1@mail.gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
	 <20091120154209.01edcbb2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:34144 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbZKUAEp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 19:04:45 -0500
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id nAL04oAt013415
	for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 00:04:50 GMT
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by zps18.corp.google.com with ESMTP id nAL04lxR012948
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 16:04:47 -0800
Received: by pzk1 with SMTP id 1so2743381pzk.33
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 16:04:47 -0800 (PST)
In-Reply-To: <20091120154209.01edcbb2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 3:42 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Fri, 20 Nov 2009 15:28:58 -0800
> Tom Herbert <therbert@google.com> wrote:
>
>> @@ -861,6 +884,9 @@ struct net_device {
>>
>> =A0 =A0 =A0 struct netdev_queue =A0 =A0 rx_queue;
>>
>> + =A0 =A0 struct dev_rps_maps =A0 =A0 *dev_rps_maps; =A0/* Per-NAPI =
maps for
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0receive packet steeing */
>> +
>
> How does this work for devices with:
> =A0 * multiqueue - one device has multiple NAPI instances

Each NAPI instance has its own map (dev_rps_maps hold the array of thes=
e maps)

> =A0 * mulitport =A0- one NAPI shared by multiple devices
>
I have not tested that, so I'm not sure.  But, I believe since the per
NAPI maps are kept in the netdevice (not in napi structure) this would
mean that each of those devices has its own per NAPI rps map(s).

Tom
