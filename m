From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 17/17] batman-adv: Avoid precedence issues in macros
Date: Fri, 28 Oct 2016 14:13:06 -0700
Message-ID: <1477689186.23018.1.camel@perches.com>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
         <20161027190150.7880-18-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>
To: Simon Wunderlich <sw@simonwunderlich.de>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0146.hostedemail.com ([216.40.44.146]:47190 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1761963AbcJ1VNR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 17:13:17 -0400
In-Reply-To: <20161027190150.7880-18-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-27 at 21:01 +0200, Simon Wunderlich wrote:
> From: Sven Eckelmann <sven@narfation.org>
> 
> It must be avoided that arguments to a macro are evaluated ungrouped (which
> enforces normal operator precendence). Otherwise the result of the macro
> is not well defined.

Curiosity:

in net/batman-adv/tp_meter.c

static int batadv_tp_send(void *arg)
{
	struct batadv_tp_vars *tp_vars = arg;
	struct batadv_priv *bat_priv = tp_vars->bat_priv;
	struct batadv_hard_iface *primary_if = NULL;
	struct batadv_orig_node *orig_node = NULL;
	size_t payload_len, packet_len;
	int err = 0;

	if (unlikely(tp_vars->role != BATADV_TP_SENDER)) {
		err = BATADV_TP_REASON_DST_UNREACHABLE;
		tp_vars->reason = err;
		goto out;
	}

	orig_node = batadv_orig_hash_find(bat_priv, tp_vars->other_end);
	if (unlikely(!orig_node)) {
		err = BATADV_TP_REASON_DST_UNREACHABLE;
		tp_vars->reason = err;
		goto out;
	}

	primary_if = batadv_primary_if_get_selected(bat_priv);
	if (unlikely(!primary_if)) {
		err = BATADV_TP_REASON_DST_UNREACHABLE;
		goto out;
	}

err is not used in the out block

Is the last if block supposed to set tp_vars->reason to err?
