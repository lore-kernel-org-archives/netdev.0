From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next V2 5/5] net/mlx4: Add VST QinQ support
Date: Mon, 25 Jul 2016 10:12:46 -0700
Message-ID: <5796488E.7080401@gmail.com>
References: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
 <1469445336-21952-6-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Moshe Shemesh <moshe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35731 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbcGYRNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 13:13:05 -0400
Received: by mail-pf0-f194.google.com with SMTP id h186so12261112pfg.2
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 10:13:04 -0700 (PDT)
In-Reply-To: <1469445336-21952-6-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-25 04:15 AM, Tariq Toukan wrote:
> From: Moshe Shemesh <moshe@mellanox.com>
> 
> Move the vf to VST QinQ mode by setting vf vlan protocol to 802.1ad.
> Read current vlan protocol as part of the vf configuration state.
> Upon setting VST QinQ, we use a mechanism of handshake to verify that
> both the vf and the pf driver version support it.
> 
> Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> ---

A typical use case I would expect is the administrator on the PF wants
to set both the outer tag (S-VLAN) and inner tag (C-VLAN) of a VM.

It seems this only allows the administrator to set the outer tag but
does allow select type of the tag.

I am mostly interested because this is establishing a UAPI and we should
be sure it can handle future use cases. What about making the
ifla_vf_vlan struct handle multiple layers of headers, by passing a
nested list of {qos + vlan + vlan_proto} tuples for each vf.

Just curious does the hardware support the above S-VLAN + C-VLAN use
case as well?

Thanks,
John
