From: Tom Herbert <therbert@google.com>
Subject: Re: RFS issue: no HW filter for paused stream
Date: Mon, 19 Sep 2011 08:13:33 -0700
Message-ID: <CA+mtBx9K8MY+WcFZpQp_85rcf316jrPpNgzqSzgMLzy7TC6eXQ@mail.gmail.com>
References: <CAP7N4Kfd9TOPr_V6+R9yVtK80eGWbkAvPE8BStG0+WhvJHaLGg@mail.gmail.com>
	<CAP7N4Kes9=VdRV8NHvk03SBg5GbohgdbGqKPABCfYbVyzZ+1ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oren@mellanox.co.il, liranl@mellanox.co.il, netdev@vger.kernel.org,
	amirv@mellanox.co.il, Ben Hutchings <bhutchings@solarflare.com>
To: Amir Vadai <amirv@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:51280 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab1ISPNh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 11:13:37 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p8JFDatg026778
	for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 08:13:37 -0700
Received: from iabz7 (iabz7.prod.google.com [10.12.102.7])
	by wpaz37.hot.corp.google.com with ESMTP id p8JFD45r031046
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 08:13:35 -0700
Received: by iabz7 with SMTP id z7so6419681iab.7
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 08:13:33 -0700 (PDT)
In-Reply-To: <CAP7N4Kes9=VdRV8NHvk03SBg5GbohgdbGqKPABCfYbVyzZ+1ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben:  Once a accel RFS flow expires (because flow is idle?), how
should it get re-instantiated if thread's CPU doesn't change?

Tom

On Sun, Sep 18, 2011 at 11:05 PM, Amir Vadai <amirv@dev.mellanox.co.il>=
 wrote:
> (Resending in plain text)
>
> Tom Hi,
> When a stream is paused, and its rule is expired while it is paused,
> no new rule will be configured to the HW when traffic resume.
>
> Scenario:
> 1. Start iperf.
> 2. Pause it using Ctrl-Z
> 3. Start another iperf (to make sure first stream rule is expired)
> 4. Stop the second stream.
> 5. Resume first stream. Traffic is not steered to the right rx-queue.
>
> From looking at the code:
> - When first stream started, RSS steered traffic to rx-queue 'x'.
> Because iperf server was running on a different CPU, a new rule was
> added and current-cpu was set to desired-cpu.
> - After paused, rule was expired and removed from HW by net driver.
> But current-cpu wasn't cleared and still is equal to desired-cpu.
> - When stream was resumed, traffic was steered again by RSS, and
> because current-cpu was equal to desired-cpu, =A0ndo_rx_flow_steer
> wasn't called and no rule was configured to the HW.
>
> Why isn't current-cpu cleared when expiring a rule?
> - Amir
>
