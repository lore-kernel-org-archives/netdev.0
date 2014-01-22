From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] net/openvswitch: Remove the skb encapsulation mark after decapsulation
Date: Wed, 22 Jan 2014 09:02:56 -0800
Message-ID: <CAEP_g=9_8aPyve-obKCLo9ByFPvSNEtNBpaUKCw7X8Tcc3U1yA@mail.gmail.com>
References: <1390403705-28690-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:38181 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752470AbaAVRDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 12:03:17 -0500
Received: by mail-ig0-f175.google.com with SMTP id uq10so14421586igb.2
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 09:03:17 -0800 (PST)
In-Reply-To: <1390403705-28690-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 7:15 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> We must unset the skb encapsulation mark before injecting the
> decapsulated packet into ovs for the rest of its journey.
>
> This follows the practice set by 0afb166 "vxlan: Add capability of Rx
> checksum offload for inner packet" and the overall idea behind the
> skb encapsulation field.
>
> Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

This should be in the common decapsulation code. It doesn't make sense
to do this here when we set the layer pointers, encap bit, etc. in
common code on transmit.
