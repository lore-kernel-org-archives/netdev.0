From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] net: ndo_gso_check() must force segmentation
Date: Mon, 22 Dec 2014 10:59:38 -0500
Message-ID: <CAEP_g=__JrSVYZPafUe-CBAA_m_S9WLAF83xKsOo7EZGsftaeg@mail.gmail.com>
References: <1417020748.29427.59.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141126.120658.498602780456343676.davem@davemloft.net> <1417027459.29427.63.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141126.153356.461494573591656082.davem@davemloft.net> <0835B3720019904CB8F7AA43166CEEB2ED585A@RTITMBSV03.realtek.com.tw>
 <1419010603.9773.84.camel@edumazet-glaptop2.roam.corp.google.com>
 <1419012837.9773.85.camel@edumazet-glaptop2.roam.corp.google.com>
 <0835B3720019904CB8F7AA43166CEEB2ED5B01@RTITMBSV03.realtek.com.tw> <1419261697.11185.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hayes Wang <hayeswang@realtek.com>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:55248 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755150AbaLVP77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 10:59:59 -0500
Received: by mail-qg0-f43.google.com with SMTP id z107so3537785qgd.30
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 07:59:58 -0800 (PST)
In-Reply-To: <1419261697.11185.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 10:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> If ndo_gso_check() returns true, it means a driver wants the stack
> to perform software segmentation, even if device features initially
> claimed hardware was able handle a TSO packet.
>
> This means netif_needs_gso() needs to modify the features.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Hayes Wang <hayeswang@realtek.com>
> Tested-by: Hayes Wang <hayeswang@realtek.com>
> Fixes: 04ffcb255f22 ("net: Add ndo_gso_check")

There's actually another problem with ndo_gso_check() - it doesn't
deal with other features like checksum offloading which usually have
similar constraints. As a result, the GSO code generates segments with
checksums offloading that immediately fails.

I have a patch that I was working on last night that behaves similarly
to yours but is also generalized to handle both cases. Let me send it
out now.
