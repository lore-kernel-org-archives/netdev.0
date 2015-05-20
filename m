From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v3 net-next 3/4] rocker: do not make neighbour entry
 changes when preparing transactions
Date: Wed, 20 May 2015 08:01:46 +0200
Message-ID: <20150520060146.GC2228@nanopsycho.orion>
References: <1432100902-10187-1-git-send-email-simon.horman@netronome.com>
 <1432100902-10187-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38263 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbbETGBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 02:01:53 -0400
Received: by wichy4 with SMTP id hy4so47116739wic.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 23:01:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432100902-10187-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 20, 2015 at 07:48:21AM CEST, simon.horman@netronome.com wrote:
>rocker_port_ipv4_nh() and in turn rocker_port_ipv4_neigh() may be
>be called with trans == SWITCHDEV_TRANS_PREPARE and then
>trans == SWITCHDEV_TRANS_COMMIT from switchdev_port_obj_set() via
>fib_table_insert().
>
>The first time that rocker_port_ipv4_nh() is called, with
>trans == SWITCHDEV_TRANS_PREPARE, _rocker_neigh_add() adds a new entry to
>the neigh table.
>
>And the second time  rocker_port_ipv4_nh() is called, with
>trans == SWITCHDEV_TRANS_COMMIT, that entry is found. This causes
>rocker_port_ipv4_nh() to believe it is not adding an entry and thus it
>frees "entry", which is still present in rocker driver's neigh table.
>
>This problem does not appear to affect deletion as my analysis is that
>deletion is always performed with trans == SWITCHDEV_TRANS_NONE.
>
>For completeness _rocker_neigh_{add,del,prepare} are updated not to
>manipulate fib table entries if trans == SWITCHDEV_TRANS_PREPARE.
>
>Fixes: c4f20321d968 ("rocker: support prepare-commit transaction model")
>Reported-by: oshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>Acked-by: Scott Feldman <sfeldma@gmail.com>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
