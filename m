From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 4/4] rocker: make rocker_port_internal_vlan_id_{get,put}()
 non-transactional
Date: Tue, 19 May 2015 09:04:10 -0700
Message-ID: <CAE4R7bBURpj6WL4k3Ppwz0a9niSkUcNkCADPLPqbuQ5MrEwUww@mail.gmail.com>
References: <1432016657-24231-1-git-send-email-simon.horman@netronome.com>
	<1432016657-24231-5-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:35541 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbbESQEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 12:04:10 -0400
Received: by qgew3 with SMTP id w3so9656790qge.2
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 09:04:10 -0700 (PDT)
In-Reply-To: <1432016657-24231-5-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 11:24 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> The motivation for this is that rocker_port_internal_vlan_id_{get,put} appear
> to only partially implement the transaction model: memory allocation
> and freeing is transactional, but hash and bitmap manipulation is not.
>
> The latter could be fixed, however, as it is not currently exercised
> due to trans always being SWITCHDEV_TRANS_NONE it seems cleaner
> to make rocker_port_internal_vlan_id_get non-transactional.
>
> Found by inspection.
> I do not believe that this change should have any run-time effect.
>
> Fixes: c4f20321d968 ("rocker: support prepare-commit transaction model")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

This works for now.  Once we switch over to using bridge's PVID, we
don't need any of this internal vlan stuff anyway, so eventually most
(all?) of this internal vlan code goes away.

Acked-by: Scott Feldman <sfeldma@gmail.com>
